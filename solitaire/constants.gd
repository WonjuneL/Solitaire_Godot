extends Node

#상수 관리

const texture_path = "res://full_page.png"

#카드의 크기(스프라이트의 크기)
const CARD_WIDTH = 57
const CARD_HEIGHT = 79
const BORDER_PADDING = 2  # 카드 선택시의 테두리 두께

#카드의 배치
const CARD_OVERLAP = CARD_HEIGHT / 4
const CARD_OFFSET_X = (1.5) * Constants.CARD_WIDTH
const CARD_TABLE_X = (3) * Constants.CARD_WIDTH
const CARD_TABLE_Y = Constants.CARD_HEIGHT * 3

const STOCK_POSITION = Vector2(Constants.CARD_TABLE_X, Constants.CARD_TABLE_Y - Constants.CARD_HEIGHT * 2)
const STOCK_OPEN_POSITION = Constants.STOCK_POSITION + Vector2(Constants.CARD_WIDTH, 0)
