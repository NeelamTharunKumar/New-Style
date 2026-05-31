"""outfit feedback history

Revision ID: 0002_outfit_feedback
Revises: 0001_initial_schema
Create Date: 2026-05-31
"""
from __future__ import annotations

from alembic import op
import sqlalchemy as sa

revision = "0002_outfit_feedback"
down_revision = "0001_initial_schema"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.create_table(
        "outfit_feedback",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("feedback_id", sa.String(length=128), nullable=False),
        sa.Column("feedback_json", sa.Text(), nullable=False),
        sa.PrimaryKeyConstraint("user_id", "feedback_id"),
    )
    op.create_index("idx_outfit_feedback_user_id", "outfit_feedback", ["user_id"])


def downgrade() -> None:
    op.drop_index("idx_outfit_feedback_user_id", table_name="outfit_feedback")
    op.drop_table("outfit_feedback")
