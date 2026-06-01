"""normalized wardrobe columns and audit events

Revision ID: 0003_normalized_columns_audit
Revises: 0002_outfit_feedback
Create Date: 2026-05-31
"""
from __future__ import annotations

from alembic import op
import sqlalchemy as sa

revision = "0003_normalized_columns_audit"
down_revision = "0002_outfit_feedback"
branch_labels = None
depends_on = None


def upgrade() -> None:
    op.add_column("wardrobe_items", sa.Column("category", sa.String(length=64), nullable=True))
    op.add_column("wardrobe_items", sa.Column("color", sa.String(length=128), nullable=True))
    op.add_column("wardrobe_items", sa.Column("style_mode", sa.String(length=32), nullable=True))
    op.add_column("wardrobe_items", sa.Column("formality", sa.Integer(), nullable=True))
    op.add_column("wardrobe_items", sa.Column("created_at", sa.DateTime(timezone=True), nullable=True))
    op.add_column("wardrobe_items", sa.Column("updated_at", sa.DateTime(timezone=True), nullable=True))
    op.create_index("idx_wardrobe_items_category", "wardrobe_items", ["category"])
    op.create_index("idx_wardrobe_items_color", "wardrobe_items", ["color"])
    op.create_index("idx_wardrobe_items_style_mode", "wardrobe_items", ["style_mode"])

    op.create_table(
        "audit_events",
        sa.Column("user_id", sa.String(length=128), nullable=False),
        sa.Column("event_id", sa.String(length=128), nullable=False),
        sa.Column("event_type", sa.String(length=128), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("event_json", sa.Text(), nullable=False),
        sa.PrimaryKeyConstraint("user_id", "event_id"),
    )
    op.create_index("idx_audit_events_user_id", "audit_events", ["user_id"])
    op.create_index("idx_audit_events_event_type", "audit_events", ["event_type"])


def downgrade() -> None:
    op.drop_index("idx_audit_events_event_type", table_name="audit_events")
    op.drop_index("idx_audit_events_user_id", table_name="audit_events")
    op.drop_table("audit_events")
    op.drop_index("idx_wardrobe_items_style_mode", table_name="wardrobe_items")
    op.drop_index("idx_wardrobe_items_color", table_name="wardrobe_items")
    op.drop_index("idx_wardrobe_items_category", table_name="wardrobe_items")
    op.drop_column("wardrobe_items", "updated_at")
    op.drop_column("wardrobe_items", "created_at")
    op.drop_column("wardrobe_items", "formality")
    op.drop_column("wardrobe_items", "style_mode")
    op.drop_column("wardrobe_items", "color")
    op.drop_column("wardrobe_items", "category")
