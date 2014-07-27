
choose_from = (arr)->
	arr[~~(Math.random() * arr.length)]

class Img # fake class
	@all = []
	@loaded_count = 0
	constructor: (fname)-> # fake constructor
		Img.all.push img
		img = new Image
		img.onload = ->
			if ++Img.loaded_count >= Img.all.length
				game_start()
		
		img.src = "images/#{fname}"
		
		return img # fake constructor


scare_1_img = Img 'scare1.jpg'
scare_2_img = Img 'scare2.jpg'
bg_img = Img 'bg.jpg'
bird_img = Img 'bird.png'
pipe_fnames = [
	'pipe.png'
	'pipe.png'
	'pipe1b.png'
	'pipe1r.png'
	'pipe20.png'
	'pipe21.png'
	'pipe23.png'
	'pipe24.png'
	'pipe32.png'
	'pipe45.png'
	'pipe-curve-65mm.png'
]
if location.hash.match 'lol'
	pipe_fnames = pipe_fnames.concat [
		'bg.jpg'
		'bird.png'
		'scare1.jpg'
		'scare2.jpg'
	]

pipe_imgs = (Img fname for fname in pipe_fnames)

# listening to Hello Internet
#Howler.mute()

music = new Howl
	urls: [
		#'music/kick-their-ass.mp3'
		#'music/kick-their-ass.ogg'
		'music/aria.ogg'
	]
	autoplay: yes
	loop: yes
	volume: 0.5

# aaaaaagh too much of this
#music.mute()

birdsong = new Howl
	urls: [
		'music/vogel.mp3'
	]
	autoplay: yes
	loop: yes
	volume: 0.5

sqeal_sound = new Howl urls: ['sound/sqeal.wav']
doom_sound = new Howl urls: ['sound/doom.wav']
flap_sound = new Howl urls: ['sound/flap.wav'], volume: 0.1

pass_obstacle_sounds = (new Howl(urls: ["sound/#{fname}"], volume: 0.6) for fname in [
	'gluglu1.wav'
	'gluglu2.wav'
	'gluglu3.wav'
	'gow337.wav'
	'pickup.wav'
])

canvas = document.createElement 'canvas'
document.body.appendChild canvas
ctx = canvas.getContext '2d'
canvas.width = 640
canvas.height = 480



entities = []
obstacle_locations = []
score = 0
max_score = 0

death_anim = 0
SPEED = 5

class Bird
	constructor: ->
		entities.push @
		@x = 200
		@y = 200
		@vx = SPEED
		@vy = 0
		@bounce_safety = 1
	
	update: ->
		@x += @vx
		@y += @vy += 0.3
		for e in entities when e instanceof Pipe
			if @x - 20 < e.x < @x + 20
				if e.from is 'bottom' and @y+15 > e.yin
					@die()
				else if e.from is 'top' and @y-15 < e.yin
					@die()
		
		@bounce_safety += 0.01
		
		if @y > canvas.height
			#console.log @bounce_safety
			if @bounce_safety >= 1
				@vy -= 5
				@y = canvas.height
				@bounce_safety = 0
			else
				@die()
		
		for o, i in obstacle_locations
			if @x > o.x
				score += 1
				(choose_from pass_obstacle_sounds).play()
				
				obstacle_locations.splice i, 1
				break
		
	die: ->
		if death_anim < 1
			death_anim = 1
			
			sqeal_sound.play()
			doom_sound.play()
	
	flap: ->
		if @vx < -3
			@vy -= 6
		else
			@vy = -7
		
		flap_sound.play()
	
	ai: ->
		o = obstacle_locations[0]
		if o
			#if @y+@vy*30 > o.y+200
			
			if @vy < 0 # going up
				if @y > o.bottom_pipe.yin
					# you need to go up to get to the opening
					# do you need to flap, though? to go up enough?
					#unless @y+@vy*30 > o.bottom_pipe.yin-20
						@flap()
			else # going down
				if @y > canvas.height-4
					# don't fall
					@flap()
				else if @y > o.bottom_pipe.yin
					# you need to go up to get to the opening
					@flap()
				else if @y > o.bottom_pipe.yin - 40 and @vy > 5
					# you're about to hit the top of the bottom pipe!
					@flap()
			
		else
			# just 
			if @y > canvas.height-40
				# don't fall
				@flap()
			else if Math.random() < 0.1 and @y > Math.random()*canvas.height
				# "have fun!"?
				@flap()
	
	draw: ->
		ctx.save()
		ctx.translate(@x, @y)
		#ctx.rotate(Math.cos(Date.now()/500))
		ctx.rotate(Math.atan2(@vy, @vx)/2+0.1)
		ctx.scale(0.5, 0.5)
		ctx.translate(-128, -100)
		ctx.drawImage(bird_img, 0, 0)
		ctx.restore()
		
class Pipe
	constructor: (@x, @yin, @from, @sprite)->
		entities.push @
		@w = @sprite.width
		
	draw: ->
		ctx.save()
		ctx.translate(@x-@w/2, @yin)
		if @from is 'top'
			ctx.scale(1, -1)
			#ctx.translate(0, @yin)
		ctx.drawImage @sprite, 0, 0
		ctx.restore()

class Game?

game_start = ->
	entities = []
	obstacle_locations = []
	score = 0
	bird = new Bird
	#ctx.drawImage(img, 0, 0) for k, img of images

	t = 0
	death_anim = 0
	do animate = ->
		t += 1
		if t % 60 is 0
			px = t*SPEED + canvas.width + 40
			py = (Math.random() * (canvas.height-100))+50
			
			p_img = pipe_imgs[~~(Math.random()*pipe_imgs.length)]
			p1 = new Pipe(px, py-70-Math.random()*30, 'top', p_img)
			p_img = pipe_imgs[~~(Math.random()*pipe_imgs.length)] if Math.random() < 0.1
			p2 = new Pipe(px, py+70+Math.random()*30, 'bottom', p_img)
			
			obstacle_locations.push {x: px, y: py, top_pipe: p1, bottom_pipe: p2}
		
		#if canvas.width isnt innerWidth or canvas.height isnt innerHeight
		#	canvas.width = innerWidth
		#	canvas.height = innerHeight
		
		#ctx.drawImage(img, 0, 0, Math.random()*500, Math.random()*500) for img in images
		
		w = (bg_img.width / bg_img.height) * canvas.height
		h = canvas.height
		# at most, the background can be visible twice
		x = (-t*6) %% w
		ctx.drawImage bg_img, x, 0, w, h
		ctx.drawImage bg_img, x-w, 0, w, h
		
		ctx.save()
		ctx.translate(-t*SPEED, 0)
		
		if location.hash.match 'ai'
			bird.ai()
		
		for e in entities
			e.draw()
			e.update?()
		
		ctx.restore()
		
		if death_anim > 0
			death_anim += 1
			
			ctx.globalCompositeOperation = choose_from ['lighter', 'darker']
			if Math.random() < 0.2 then ctx.globalCompositeOperation = 'difference'
			ctx.drawImage(
				(if death_anim % 2 is 0 then scare_1_img else scare_2_img)
				0, 0, canvas.width, canvas.height
			)
			ctx.globalCompositeOperation = 'source-over'
			
			if death_anim > 6
				death_anim = 0
				
				game_start()
				return # don't request another animation frame
		
		max_score = Math.max(score, max_score)
		
		
		# draw scores
		draw_text = (text, align, x, y)->
			ctx.font = '30px Arial'
			ctx.font = '30px Papyrus'
			ctx.textBaseline = 'top'
			ctx.textAlign = align
			
			for i in [0..3]
				ctx.strokeStyle = "hsla(255, #{i*100}%, #{i*100}%, 0.1)" #'#87C9E1' #
				ctx.lineWidth = 30 - i*5
				ctx.strokeText(text, x, y)
				
			#ctx.strokeStyle = '#56BD92' #'rgba(255, 255, 255, 0.1)' #'#87C9E1' #
			#ctx.lineWidth = 30
			#ctx.strokeText(text, x, y)
			
			ctx.strokeStyle = 'black'
			ctx.lineWidth = 5
			ctx.strokeText(text, x, y)
			
			ctx.fillStyle = 'white'
			ctx.fillText(text, x, y)
		
		draw_text "Score: #{score}", 'left', 10, 10
		draw_text "Best Score: #{max_score}", 'right', canvas.width - 10, 10
		# not quite sure the MAXIMUM score is always the BEST one but yeah
		
		# aqua-ish tint
		ctx.fillStyle = "hsla(160, 50%, 60%, 0.3)"
		ctx.fillRect(0, 0, canvas.width, canvas.height)
		
		requestAnimationFrame animate
	
	###flap = -> bird.flap()
	
	document.body.addEventListener 'mousedown', flap
	document.body.addEventListener 'touchstart', flap
	document.body.addEventListener 'keydown', flap###
	
	document.body.onmousedown = -> bird.flap()
	document.body.ontouchstart = -> bird.flap()
	document.body.onkeydown = -> bird.flap()
