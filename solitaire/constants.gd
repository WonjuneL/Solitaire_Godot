extends Node

const CARD_WIDTH = 57
const CARD_HEIGHT = 79
const BORDER_PADDING = 2  # 카드 선택시의 테두리 두께
const CARD_OVERLAP = CARD_HEIGHT / 4
const CARD_OFFSET_X = 1.5 * Constants.CARD_WIDTH
const CARD_TABLE_X = (3.5) * Constants.CARD_WIDTH
const CARD_TABLE_Y = Constants.CARD_HEIGHT * 3
const STOCK_POSITION = Vector2(Constants.CARD_TABLE_X, Constants.CARD_TABLE_Y - Constants.CARD_HEIGHT * 2)
const STOCK_OPEN_POSITION = Constants.STOCK_POSITION + Vector2(Constants.CARD_WIDTH, 0)

# 카드 뒷면 좌표
const BACK_UV_X = 2 + 1 * (Constants.CARD_WIDTH + 2)  # 2번째 행
const BACK_UV_Y = 2 + 4 * (Constants.CARD_HEIGHT + 2)  # 5번째 열
# 카드 뒷면 좌표(검정)
const BACK_K_UV_X = 2 + 11 * (Constants.CARD_WIDTH + 2)  # 2번째 행
const BACK_K_UV_Y = 2 + 4 * (Constants.CARD_HEIGHT + 2)  # 5번째 열
#조커
const JOCKER_UV_X = 2 + 2 * (Constants.CARD_WIDTH + 2)  #3행
const JOCKER_UV_Y = 2 + 4 * (Constants.CARD_HEIGHT + 2) #5열
