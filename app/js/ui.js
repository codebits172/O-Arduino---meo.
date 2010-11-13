function UI(parent_s, child_s){
	this._parent = parent_s; 
	this._child = child_s; 
	this.engine = new Engine()
}

UI.prototype.RemoteCommandElement = function(id,description,code){
	return "<div id=\""+id+"\">"+code+"</div>";
}

UI.prototype.RemoteElement = function(id,stdid,title,ip,address){
	return "<a id=\""+id+"\" href=\"#\" onclick=\"ui.genRemoteCommands('"+id+"')\">"+title+"</a><br/>";
}

UI.prototype.bindRemotes = function() {
	this.engine.getRemotes(function(data){
		for(i=0; i<data.length; ++i){
			var value = data[i];
			$(this.RemoteElement(value.ID, value.StandardID, value.Title, value.IP, value.Address)).appendTo(this._parent);
		}
	}.bind(this));
}

UI.prototype.genRemoteCommands = function(id){
	this.engine.getRemoteCommands(id, function(data){
		for(i=0; i<data.length; ++i){
			var value = data[i];
			$(this.RemoteCommandElement(value.ID, value.Description, value.Code)).appendTo(this._child);
		}
	}.bind(this));
}

