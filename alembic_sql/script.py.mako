"""${message}

Revision ID: ${up_revision}
Revises: ${down_revision | comma,n}
Create Date: ${create_date}

"""
from alembic import op
import sqlalchemy as sa
${imports if imports else ""}

from alembic_sql import common

# revision identifiers, used by Alembic.
revision = ${repr(up_revision)}
down_revision = ${repr(down_revision)}
branch_labels = ${repr(branch_labels)}
depends_on = ${repr(depends_on)}

u_sqls = ['upgrade.sql']
d_sqls = ['downgrade.sql']

common.create_revision_structure(revision, u_sqls, d_sqls)


def upgrade():
    common.execute_file(op.get_bind(), revision, u_sqls, True)


def downgrade():
    if common.is_downgrade_disabled():
        print(common.get_downgrade_warning())
    else:
        common.execute_file(op.get_bind(), revision, d_sqls, False)
