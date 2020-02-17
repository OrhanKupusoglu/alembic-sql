import os
from alembic import context
from alembic import op
from alembic.script import ScriptDirectory
from alembic.config import Config
from sqlalchemy.dialects import postgresql
import psycopg2


def get_path_to_sql(revision):
    config = Config('alembic.ini')
    script_location = config.get_section_option('alembic', 'script_location')
    version_location = 'versions'
    return os.path.abspath(os.path.join(script_location, version_location, revision))

def create_revision_file(revision, file_sql):
    path_to_sql = get_path_to_sql(revision)
    try:
        fo = open(os.path.join(path_to_sql, file_sql), "w")
    except OSError:
        print('  failed')
    else:
        print('  done')
        header_sql = '-- ' + ('-' * 77) + "\n-- " + file_sql + ' | ' + revision + "\n-- " + ('-' * 77) + "\n\n\n"
        fo.write(header_sql);
    fo.close()

def create_revision_structure(revision, u_sqls, d_sqls):
    path_to_sql = get_path_to_sql(revision)
    if not os.path.exists(path_to_sql):
        print('  Creating directory {} ...'.format(path_to_sql), end = '')
        try:
            os.mkdir(path_to_sql)
        except OSError:
            print('  failed')
        else:
            print('  done')

        for u_sql in u_sqls:
            print('  Creating upgrade file {} ...'.format(u_sql), end = '')
            create_revision_file(revision, u_sql)

        for d_sql in d_sqls:
            print('  Creating downgrade file {} ...'.format(d_sql), end = '')
            create_revision_file(revision, d_sql)

def is_downgrade_enabled():
    enabled = context.config.get_section_option('alembic-sql', 'downgrade_enabled').lower()
    downgrade_enabled = (enabled  == 'true') or (enabled  == 'yes')  or (enabled  == 'on') or (enabled  == '1')
    return downgrade_enabled

def is_downgrade_disabled():
    return not is_downgrade_enabled()

def get_downgrade_warning():
    return '\nWARNING - DB downgrade is disabled\n'

def get_header_loc_upgrade():
    return '+++ UPGRADE LoC:'

def get_header_loc_downgrade():
    return '+++ DOWNGRADE LoC:'

def execute_file(conn, revision, sqls, is_upgrade):
    loc = 0
    if is_upgrade:
        title = get_header_loc_upgrade()
    else:
        title = get_header_loc_downgrade()

    for sql in sqls:
        loc = execute_command(conn, revision, sql)
        print(title, loc, '\n', sep = '\t')

def execute_command(conn, revision, file_name):
    """Read raw SQL strings in a file <filename> and execute them on <conn>

    SQL strings are seperated by ';'.

    """
    header_file = '-' * 80
    header_sql = '_' * 38 + ' SQL ' + '_' * 37

    abs_file_path = os.path.abspath(os.path.join(get_path_to_sql(revision), file_name))

    print('{}\nPATH: {}\n{}\n'.format(header_file, abs_file_path, header_file))

    fd = open(abs_file_path, encoding='utf-8', mode='r')
    sql_file = fd.read()
    fd.close()

    loc = 0
    commands = sql_file.split(';')

    for command in commands:
        command = command.strip()

        if (command != ''):
            # eliminate comments
            lines = command.splitlines(keepends=True)

            lines = [line for line in lines if not (line.strip().startswith('--') or line.strip().startswith('#'))]

            sql = ''.join(lines).strip()

            if (sql.startswith('/*') and sql.endswith('*/')):
                sql = ''

            if (sql != ''):
                sql += ';'

            if (sql == ''):
                print('<comment>')
            else:
                loc = loc + len(sql.splitlines())
                try:
                    conn.execute(sql)
                except psycopg2.ProgrammingError as perr:
                    print('+++ PostgreSQL DB ERROR:', perr)
                except psycopg2.InternalError as ierr:
                    print('+++ PostgreSQL DRIVER ERROR:', ierr)
                except Exception as err:
                    print('+++ GENERIC ERROR:', err)
                finally:
                    print(header_sql, sql, sep = '\n')

                print()

    return loc
