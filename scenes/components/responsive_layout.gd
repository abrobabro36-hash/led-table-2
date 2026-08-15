class_name ResponsiveLayout
extends RefCounted

const COMPACT_WIDTH := 520.0
const TABLET_WIDTH := 820.0
const PHONE_PAGE_MARGIN := 16
const TABLET_PAGE_MARGIN := 28
const ACTION_BAR_HEIGHT := 72
const SAFE_SPACING := 16


static func is_tablet(width: float) -> bool:
	return width >= TABLET_WIDTH


static func page_margin(width: float) -> int:
	return TABLET_PAGE_MARGIN if is_tablet(width) else PHONE_PAGE_MARGIN


static func home_columns(width: float) -> int:
	if width >= TABLET_WIDTH:
		return 4
	if width >= COMPACT_WIDTH:
		return 3
	return 2


static func persistent_action_inset() -> int:
	return ACTION_BAR_HEIGHT + SAFE_SPACING
