extends Node
var tehuda_image_random
var tehuda_image
var P1_card_drawing = [0,0,0,0,0,0,0,0,0]
var P1_card_already_drawed = [0,0,0,0,0,0,0,0,0,0]
var back2front = [0,0,0,0,0,0,0,0,0]
onready var texture = [$textures.texture0000,$textures.texture0001,$textures.texture0002,$textures.texture0003,$textures.texture0004,$textures.texture0005,$textures.texture0006,$textures.texture0007]
onready var P1tehuda = [$P1tehuda0,$P1tehuda1,$P1tehuda2,$P1tehuda3,$P1tehuda4,$P1tehuda5,$P1tehuda6,$P1tehuda7]
onready var P1tehuda_colision = [$P1tehuda0/CollisionShape2D,$P1tehuda1/CollisionShape2D,$P1tehuda2/CollisionShape2D,$P1tehuda3/CollisionShape2D,$P1tehuda4/CollisionShape2D,$P1tehuda5/CollisionShape2D,$P1tehuda6/CollisionShape2D,$P1tehuda7/CollisionShape2D]
var P1_tehuda_count = 0
onready var P1tehuda_Sprite = [$P1tehuda0/Sprite,$P1tehuda1/Sprite,$P1tehuda2/Sprite,$P1tehuda3/Sprite,$P1tehuda4/Sprite,$P1tehuda5/Sprite,$P1tehuda6/Sprite,$P1tehuda7/Sprite]
onready var P1tehuda_Sprite2 = [$P1tehuda0/Sprite2,$P1tehuda1/Sprite2,$P1tehuda2/Sprite2,$P1tehuda3/Sprite2,$P1tehuda4/Sprite2,$P1tehuda5/Sprite2,$P1tehuda6/Sprite2,$P1tehuda7/Sprite2]
var screen_w = 1280
var screen_h = 720
var card_width = 288
var card_height = 512
var image_ratio = 0.635
var slide = card_width * image_ratio
var slide2 = (screen_w - (slide / 2) - (screen_w / 2)) / 19

# (画像ファイルの横幅)288 * (縮尺)0.635 = (カード横幅)182.88
# 画面端から中央に移動させたい場合
# (画面の横幅)1280 - (カード横幅の半分)91.44 = 1188.56
# 1188.56 - 640 = 548.56    548.56 / 19 = (一回ごとのズレ幅)28.8716    182.88 / 19 = 9.6252    91.44 / 19 = 4.8126
var dragging = false
var mouse_on_P1tehuda = [0,0,0,0,0,0,0,0,0]
var P1tehuda_past_position = [0,0,0,0,0,0,0,0,0]
var past_position
var tehudabasyoirekae
var karitexture
var mouse_on_count

func _ready():
	P1_card_already_drawed[-1] = 1
	for n in 9:
		P1tehuda_past_position[n] = Vector2(0,0)
	
func _tehuda_random():
	randomize()
	tehuda_image_random = randi() % 8
	for n in 8:
		if tehuda_image_random == n:
			tehuda_image = texture[n]

func _process(_delta):
#	print(P1_card_drawing[P1_tehuda_count])
#	print(P1_card_already_drawed[P1_tehuda_count])
#	print(P1_card_already_drawed[-1 + P1_tehuda_count])
#	print(P1_tehuda_count)
	# ボタンを押す度にカードをランダムに設定し、画面右端の山札の位置を定める、9枚目以降は引けない
	if (Input.is_action_just_pressed("DrawCard")) && (P1_card_drawing[P1_tehuda_count] == 0) && (P1_card_already_drawed[P1_tehuda_count] == 0) && (P1_card_already_drawed[-1 + P1_tehuda_count] == 1) && (P1_tehuda_count < 8):
		P1_card_drawing[P1_tehuda_count] = 1
		_tehuda_random()
		P1tehuda_Sprite[P1_tehuda_count].texture = tehuda_image
		P1tehuda[P1_tehuda_count].position.x = screen_w - slide/2
		P1tehuda[P1_tehuda_count].position.y = screen_h - ((card_height * image_ratio) / 2)
	# カードを引いて手札に加える際にカードを回転させる2
	if (P1_card_drawing[P1_tehuda_count] == 1) && (back2front[P1_tehuda_count] == 1) && (P1_card_already_drawed[P1_tehuda_count] == 0):
		P1tehuda[P1_tehuda_count].scale.x += image_ratio / 10
		if (P1tehuda[P1_tehuda_count].scale.x > image_ratio):
			back2front[P1_tehuda_count] = 0
			P1_card_drawing[P1_tehuda_count] = 0
			P1_card_already_drawed[P1_tehuda_count] = 1
			P1_tehuda_count += 1
	# 8枚目の時だけは全カードを少しずつ重ね合わせる
			if P1_tehuda_count == 8:
				for n in 8:
					P1tehuda_colision[n].scale.x = 0.8
	# カードを引いて手札に加える際にカードを回転させる1
	if (P1_card_drawing[P1_tehuda_count] == 1) && (back2front[P1_tehuda_count] == 0) && (P1_card_already_drawed[P1_tehuda_count] == 0):
		P1tehuda[P1_tehuda_count].scale.x -= image_ratio / 10
		if (P1tehuda[P1_tehuda_count].scale.x < 0.01):
			P1tehuda_Sprite2[P1_tehuda_count].hide()
			P1tehuda_Sprite[P1_tehuda_count].show()
			back2front[P1_tehuda_count] = 1
	# カードを引いて画面右端の山札から手札に加える際にスライドして配置調整
	if (P1_card_drawing[P1_tehuda_count] == 1) && (P1_tehuda_count < 7):
		P1tehuda[P1_tehuda_count].position.x -= slide2 - ((slide/19) * P1_tehuda_count)
		for n in P1_tehuda_count:
			P1tehuda[n].position.x -= (slide / 19 / 2)
		P1tehuda[P1_tehuda_count].position.x -= ((slide / 19 / 2) * P1_tehuda_count)
		#カードを引いた後の全てのカードの定位置を保存しておく
		for n in 8:
			P1tehuda_past_position[n] = P1tehuda[n].position
	# 8枚目のカードを引いた時は全カードを少しずつ重ね合わせる
	# (カード横幅)182.88 / 7枚のカード = 26.1257    26.1257 / 19 = 1.375
	if (P1_card_drawing[7] == 1):
		for n in 6:
			P1tehuda[n+1].position.x -= ((slide / 7) / 19) * n +1.5
		for n in 8:
			P1tehuda_past_position[n] = P1tehuda[n].position

func _input(event):
	for n in 8:
	# カードにマウスが重なっている状態でクリックする（一度にドラッグ出来るのは一枚まで
		if mouse_on_P1tehuda[n] == 1 && (mouse_on_P1tehuda[0] + mouse_on_P1tehuda[1] + mouse_on_P1tehuda[2] + mouse_on_P1tehuda[3] + mouse_on_P1tehuda[4] + mouse_on_P1tehuda[5] + mouse_on_P1tehuda[6] + mouse_on_P1tehuda[7]) < 2:
			if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
				past_position =  P1tehuda_past_position[n] - event.position
				if not dragging and event.pressed:
						dragging = true
				# マウスのボタンを離した場所に応じてカードの場所交換、マナチャージ、墓地送り、バトルゾーン送り、
				if dragging and not event.pressed:
					dragging = false
					# 墓地に送ってカードを1枚減らす
					for n2 in 8:
						if P1tehuda_Sprite[n].rotation_degrees == 180:
							P1tehuda[n].position.y = 1000
							P1tehuda_past_position[n].y = 1000
							P1_card_already_drawed[n] = 0
							P1tehuda_Sprite[n].rotation_degrees = 0
							P1tehuda_Sprite2[P1_tehuda_count-1].show()
							for n3 in 8:
								if P1_tehuda_count == 8:
									P1tehuda[n3].position.x = slide*n3
								if n < n3:
									P1tehuda[n3].position.x -= (slide / 2)
								if n3 < n:
									P1tehuda[n3].position.x += (slide / 2)
								P1tehuda_past_position[n3].x = P1tehuda[n3].position.x
							P1_tehuda_count -= 1
							for n4 in 7:
								if n == P1_tehuda_count-n4-1:
									P1tehuda_Sprite[n].texture = P1tehuda_Sprite[P1_tehuda_count-n4].texture
									for n5 in n4:
										P1tehuda_Sprite[P1_tehuda_count-n4+n5].texture = P1tehuda_Sprite[P1_tehuda_count-n4+n5+1].texture
									P1tehuda[n].position = P1tehuda[P1_tehuda_count-n4].position
									for n5 in n4:
										P1tehuda[P1_tehuda_count-n4+n5].position = P1tehuda[P1_tehuda_count-n4+n5+1].position
									P1tehuda_past_position[n] = P1tehuda[n].position
									for n5 in n4:
										P1tehuda_past_position[P1_tehuda_count-n4+n5] = P1tehuda[P1_tehuda_count-n4+n5].position
									P1_card_already_drawed[n] = 1
									P1_card_already_drawed[P1_tehuda_count] = 0
									P1tehuda[P1_tehuda_count].position.y = 1000
							break
					# 画面下部に移動させた場合はカード同士の場所交換
					for n2 in 8:
						if P1tehuda[n2].rotation_degrees == 20 || P1tehuda[n2].rotation_degrees == -20:
							# ①ドラッグしたカードの絵柄を仮テクスチャに保存
							karitexture = P1tehuda_Sprite[n].texture
							# 両端のカードを動かす場合
							if n == 0 || n == P1_tehuda_count - 1:
								for n3 in (P1_tehuda_count - 1):
									if (n2+(P1_tehuda_count-1-n3) * (P1tehuda[n2].rotation_degrees/20)) < 0 || 7 < (n2+(P1_tehuda_count-1-n3) * (P1tehuda[n2].rotation_degrees/20)):
										pass
									if 0 <= (n2+(P1_tehuda_count-1-n3) * (P1tehuda[n2].rotation_degrees/20)) && (n2+(P1_tehuda_count-1-n3) * (P1tehuda[n2].rotation_degrees/20)) <= 7:
										P1tehuda_Sprite[n2+(P1_tehuda_count-1-n3) * (P1tehuda[n2].rotation_degrees/20)].texture = P1tehuda_Sprite[n2+(P1_tehuda_count-2-n3) * (P1tehuda[n2].rotation_degrees/20)].texture
							# 中間のカードを動かす場合
							if n != 0 && n != P1_tehuda_count - 1:
								for n4 in P1_tehuda_count-2:
									if n2-n == -(n4+1)*(P1tehuda[n2].rotation_degrees/20):
										for n5 in n4+1:
											P1tehuda_Sprite[n2+((n4+1)-n5)*(P1tehuda[n2].rotation_degrees/20)].texture = P1tehuda_Sprite[n2+((n4+1)-n5-1)*(P1tehuda[n2].rotation_degrees/20)].texture
							# ①で仮テクスチャに保存した画像をn2に入れる
							P1tehuda_Sprite[n2].texture = karitexture
							P1tehuda[n2-1].rotation_degrees = 0
							P1tehuda[n2].rotation_degrees = 0
							if (n2+1) < 8:
								P1tehuda[n2+1].rotation_degrees = 0
					# どれにも該当しなかった場合はカードを元の位置に戻す
					P1tehuda_Sprite[n].position = Vector2(0,0)
					if P1_card_already_drawed[n] == 1:
						P1tehuda[n].position.y = screen_h - ((card_height * image_ratio) / 2)
					P1tehuda[n].z_index = 0
					mouse_on_P1tehuda[n] = 0
			# ドラッグしている最中はマウスポインタと同時に対象を動かす
			if event is InputEventMouseMotion and dragging:
				P1tehuda_Sprite[n].position = (event.position - P1tehuda_past_position[n] + past_position) * (1 / image_ratio)
				# カードが元の位置にある時
				if (mouse_on_P1tehuda[0] && event.position.x <= P1tehuda[1].position.x) || (mouse_on_P1tehuda[P1_tehuda_count-1] && P1tehuda[P1_tehuda_count-2].position.x <= event.position.x) || (P1tehuda_past_position[n].x - (card_width * image_ratio) <= event.position.x && event.position.x <= P1tehuda_past_position[n].x + (card_width * image_ratio)) || screen_h - card_height*image_ratio/3*2 > event.position.y:
					for n3 in P1_tehuda_count:
						P1tehuda[P1_tehuda_count-1-n3].rotation_degrees = 0
				# 左側のどれかのカードを右端にドラッグして入れ替え
				if mouse_on_P1tehuda[n] && (P1_tehuda_count > (n+1)) && (P1tehuda[P1_tehuda_count-1].position.x < event.position.x) && screen_h - card_height*image_ratio/3*2 < event.position.y:
					for n3 in P1_tehuda_count-1:
						P1tehuda[P1_tehuda_count-2-n3].rotation_degrees = 0
					P1tehuda[P1_tehuda_count-1].rotation_degrees = -20
				# 右側のどれかのカードを左端にドラッグして入れ替え
				if (not mouse_on_P1tehuda[0] && (mouse_on_P1tehuda[n] && P1_tehuda_count > (n+1))) || (mouse_on_P1tehuda[P1_tehuda_count-1]) && screen_h - card_height*image_ratio/3*2 < event.position.y:
					if event.position.x < P1tehuda[0].position.x:
						P1tehuda[0].rotation_degrees = 20
						for n3 in P1_tehuda_count-1:
							P1tehuda[n3+1].rotation_degrees = 0
				# カードが3枚以上ある時に左側のどれかのカードを右端以外にドラッグして入れ替え
				for n3 in P1_tehuda_count-2:
					for n4 in n3+1:
						if P1_tehuda_count > n3+2 && mouse_on_P1tehuda[n4] && (P1tehuda[n3+1].position.x < event.position.x && event.position.x < P1tehuda[n3+2].position.x) && screen_h - card_height*image_ratio/3*2 < event.position.y:
							for n5 in P1_tehuda_count:
								P1tehuda[n5].rotation_degrees = 0
							P1tehuda[n3+1].rotation_degrees = -20
							P1tehuda[n3+2].rotation_degrees = 5
				# カードが3枚以上ある時に右側のどれかのカードを左端以外にドラッグして入れ替え
				for n3 in P1_tehuda_count-2:
					for n4 in n3+1:
						if P1_tehuda_count > n3+2 && mouse_on_P1tehuda[n3+2] && (P1tehuda[n4].position.x < event.position.x && event.position.x < P1tehuda[n4+1].position.x) && screen_h - card_height*image_ratio/3*2 < event.position.y:
							for n5 in P1_tehuda_count:
								P1tehuda[n5].rotation_degrees = 0
							P1tehuda[n4].rotation_degrees = -5
							P1tehuda[n4+1].rotation_degrees = 20
				# カードが一枚だけの時、或いはカードが上側に近い時は傾けない
				if P1_tehuda_count == 1 || screen_h - card_height*image_ratio/3*2 > event.position.y:
					P1tehuda[0].rotation_degrees = 0
				# 墓地送り
				if event.position.y < 300 && mouse_on_P1tehuda[n] == 1:
					P1tehuda_Sprite[n].rotation_degrees = 180
				if event.position.y >= 300 && mouse_on_P1tehuda[n] == 1:
					P1tehuda_Sprite[n].rotation_degrees = 0

	if event is InputEventMouseMotion:
		if not dragging:
			for n6 in 8:
				if P1_tehuda_count < 8:
					if P1tehuda_past_position[n6].x - slide/2 < event.position.x && event.position.x <= P1tehuda_past_position[n6].x + slide/2 && screen_h - (card_height * image_ratio) < event.position.y && event.position.y < screen_h:
						if P1_card_already_drawed[n6]:
							P1tehuda[n6].position.y = 520
							P1tehuda[n6].z_index = 1
							mouse_on_P1tehuda[n6] = 1
					if event.position.x < P1tehuda_past_position[n6].x - slide/2 || P1tehuda_past_position[n6].x + slide/2 <= event.position.x || event.position.y < screen_h - (card_height * image_ratio) || screen_h < event.position.y:
						if P1_card_already_drawed[n6]:
							P1tehuda[n6].position.y = screen_h - ((card_height * image_ratio) / 2)
							P1tehuda[n6].z_index = 0
							mouse_on_P1tehuda[n6] = 0
				if P1_tehuda_count == 8:
					if P1tehuda_past_position[n6].x - slide/2 + ((card_width * image_ratio) / 7) < event.position.x && event.position.x <= P1tehuda_past_position[n6].x + slide/2 - ((card_width * image_ratio) / 7) && screen_h - (card_height * image_ratio) < event.position.y && event.position.y < screen_h:
						if P1_card_already_drawed[n6]:
							P1tehuda[n6].position.y = 520
							P1tehuda[n6].z_index = 1
							mouse_on_P1tehuda[n6] = 1
					if event.position.x < P1tehuda_past_position[n6].x - slide/2 + ((card_width * image_ratio) / 7) || P1tehuda_past_position[n6].x + slide/2 - ((card_width * image_ratio) / 7) <= event.position.x || event.position.y < screen_h - (card_height * image_ratio) || screen_h < event.position.y:
						if P1_card_already_drawed[n6]:
							P1tehuda[n6].position.y = screen_h - ((card_height * image_ratio) / 2)
							P1tehuda[n6].z_index = 0
							mouse_on_P1tehuda[n6] = 0

