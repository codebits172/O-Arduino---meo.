var remotes = [{ID: "1", StandardID: "1",Title: "Remote 1",IP: "1270",Address: "1986"},{ID: "2", StandardID: "1", Title: "Remote 2", IP: "1270", Address: "1902"},{ID: "3",StandardID: "2",Title: "Remote 3",IP: "1270",Address:"1111"}];
var remote_commands = [{ID:"3",Description:"Digit key 1",Code:"0"},{ID:"4",Description:"Digit key 2",Code:"1"},{ID:"22",Description:"Digit key 3",Code:"2"},{ID:"23",Description:"Digit key 4",Code:"3"},{ID:"24",Description:"Digit key 5",Code:"4"},{ID:"25",Description:"Digit key 6",Code:"5"},{ID:"26",Description:"Digit key 7",Code:"6"},{ID:"27",Description:"Digit key 8",Code:"7"},{ID:"28",Description:"Digit key 9",Code:"8"},{ID:"29",Description:"Digit key 0",Code:"9"},{ID:"30",Description:"Channel +",Code:"16"},{ID:"31",Description:"Channel -",Code:"17"},{ID:"32",Description:"Volume +",Code:"18"},{ID:"33",Description:"Volume -",Code:"19"},{ID:"34",Description:"Mute",Code:"20"},{ID:"35",Description:"Power",Code:"21"},{ID:"36",Description:"Reset",Code:"22"},{ID:"37",Description:"Audio Mode",Code:"23"},{ID:"38",Description:"Standby",Code:"47"}];

function Engine() {
	this.remotes = new Object()

}

Engine.prototype.setRemotes = function(data){	
	for(i=0; i<data.length; ++i){
		key = data[i]
		id = data[i].ID
		if  ( (this.remotes[id] == undefined) || (this.remotes[id] == "") ){
			this.remotes[key.ID] = key
		}
	}
	localStorage.setItem('remotes', JSON.stringify(this.remotes))
}

Engine.prototype.setCommands = function(id, data){
	var remote = this.remotes[id.toString()]
	if ((remote == null) || (remote == ""))
		return -1;
	if (remote.commands == undefined){
		remote.commands = Array()	
	}
	for(i=0; i<data.length; ++i){
		if (remote.commands.indexOf(data[i]) == -1){
			remote.commands.push(data[i])		
		}			
	}
	this.setInterface(id.toString(), remote);
	this.remotes[id.toString()] = remote;
	localStorage.setItem('remotes', JSON.stringify(this.remotes))
}

Engine.prototype.setInterface = function(id,remote){
	var remote = this.remotes[id.toString()]
	var commands = remote.commands
	for(i=0; i<remote.commands.length; ++i){
		var method = remote.commands[i].Description.replace(/[ ]/g,'_');
		var eval_str = "remote."+method+"=function(){$.get('/command?i="+remote.ID+"&c="+remote.commands[i].Code+"')}";
		var result = eval(eval_str);
		var result2 = eval(eval_str);
	}
	this.remotes[id.toString()]=remote;
}
/**
  * @url /api/?a=GetRemotes
  * @description: It returns all supported remote controls 
  */
Engine.prototype.getRemotes = function(fn) {
	$.getJSON("/api?a=GetRemotes", function(data){
		fn(data);	
		this.setRemotes(data);
	}.bind(this));
	/*fn(remotes);
	this.setRemotes(remotes);*/
}

/**
  * @url /api/?a=GetStandardCodes&standardid=<param>
  * @description: It returns all codes for remote control who's ID=<param>
  */
Engine.prototype.getRemoteCommands = function(_id, fn) {
	$.getJSON("/api?a=GetStandardCommands&standardid="+_id, function(data){
		fn(data);
		this.setCommands(_id, data);
	}.bind(this));
	/*fn(remote_commands);
	this.setCommands(_id, remote_commands);*/
}

