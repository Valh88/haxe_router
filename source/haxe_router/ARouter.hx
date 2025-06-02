package haxe_router;

import haxe.ui.core.Component;

abstract class ARouter
{
	abstract public function addRoute(path:String, viewFactory:Void->Component):Void;
	abstract public function navigate(path:String, ?params:Map<String, String>):Bool;
	abstract public function back():Void;
	abstract public function getCurrentPath():String;
	abstract public function getParam(name:String):Null<String>;
	abstract public function setParams(params:Map<String, String>):Void;
}
