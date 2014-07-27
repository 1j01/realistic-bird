
var display_canvas = document.createElement("canvas");
var dctx = display_canvas.getContext("2d");
document.body.appendChild(display_canvas);

var canvas = document.createElement("canvas");
var ctx = canvas.getContext("2d");
canvas.width = 220;
canvas.height = 140;

var overlay_canvas = document.createElement("canvas");
var octx = overlay_canvas.getContext("2d");

var display = function(){
	dctx.fillStyle = '#000';
	dctx.fillRect(0, 0, display_canvas.width, display_canvas.height);
	
	dctx.imageSmoothingEnabled = false;
	dctx.mozImageSmoothingEnabled = false;
	dctx.webkitImageSmoothingEnabled = false;
	var scale = 1;
	while(canvas.width * scale < display_canvas.width && canvas.height * scale < display_canvas.height){
		scale += 1;
	}
	scale -= 1;
	var s = Math.min(scale, 3);
	var w = canvas.width * s;
	var h = canvas.height * s;
	
	if(overlay_canvas.width !== w || overlay_canvas.height !== h){
		overlay_canvas.width = w;
		overlay_canvas.height = h;
		
		// "scanlines"
		var id = octx.getImageData(0, 0, w, h);
		for(var y=0; y<h; y+=1){
			for(var x=0; x<w*4; x+=4){
				id.data[4*y*w + x+0] = Math.sin(y/50) * ((y%s==0) ? 0 : (y%s==1) ? 10 : 100);
				id.data[4*y*w + x+1] = Math.sin(y/50) * ((y%s==0) ? 0 : (y%s==1) ? 10 : 100);
				id.data[4*y*w + x+2] = Math.sin(y/50) * ((y%s==0) ? 0 : (y%s==1) ? 10 : 100);
				id.data[4*y*w + x+3] = ((y%s==0) ? 100 : (y%s==1) ? 100 : 0);
			}
		}
		octx.putImageData(id, 0, 0);
		
		// vignette
		var x = w/2;
		var y = h/2;
		var r = w*0.6;
		var g = octx.createRadialGradient(x, y, r/7, x, y, r);
		g.addColorStop(0.5, 'rgba(205, 205, 50, 0.1)');
		g.addColorStop(0, 'rgba(105, 105, 50, 0.1)');
		g.addColorStop(1, 'rgba(0, 0, 0, 0.7)');
		octx.fillStyle = g;
		octx.beginPath();
		octx.arc(x, y, r, 0, Math.PI*2, false);
		octx.fill();
	}
	
	s = scale;
	w = canvas.width * s;
	h = canvas.height * s;
	
	dctx.drawImage(
		canvas,
		~~((display_canvas.width - w) / 2),
		~~((display_canvas.height - h) / 2),
		w, h
	);
	
	dctx.drawImage(
		overlay_canvas,
		~~((display_canvas.width - w) / 2),
		~~((display_canvas.height - h) / 2),
		w, h
	);
};


var glitch = function(ctx){
	var w = ctx.canvas.width;
	var h = ctx.canvas.height;
	var id = ctx.getImageData(0, 0, w, h);
	for(var t = 0; t < Math.random()*100; t++){
		var s = ~~(Math.random()*id.data.length);
		var e = ~~(Math.random()*(id.data.length-15))+15;
		var g = ~~(Math.random()*(320*480/25-15))+1;
		for(var i = s; i < e; i++){
			id.data[i] = id.data[i-g];
		}
	}
	ctx.putImageData(id, 0, 0);
};

var XXX = 0.25;
var YYY = 1;
var warp = function(ctx){
	XXX = Math.min(XXX + 0.0001, 0.5);
	YYY = Math.min(YYY + 0.0002, 1);
	var w = ctx.canvas.width;
	var h = ctx.canvas.height;
	var id = ctx.getImageData(0, 0, w, h);
	var id2 = ctx.getImageData(0, 0, w, h);
	for(var y=0; y<h; y+=1){
		for(var x=0; x<w*4; x+=4){
			var X = ~~(Math.cos(x / w * Math.PI * XXX) * w/2.3 + w/2);
			var Y = ~~(Math.sin(y / h * Math.PI * YYY) * h/2.3 + h/2);
			id2.data[4*y*w + x+0] = id.data[4*Y*w + X*4+0];
			id2.data[4*y*w + x+1] = id.data[4*Y*w + X*4+1];
			id2.data[4*y*w + x+2] = id.data[4*Y*w + X*4+2];
		}
	}
	ctx.putImageData(id2, 0, 0);
};

(window.onresize = function(){
	display_canvas.width = document.body.clientWidth;
	display_canvas.height = document.body.clientHeight;
	display();
})();
