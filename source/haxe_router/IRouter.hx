package haxe_router;

import haxe.ui.core.Component;


interface IRouter {
    function addRoute(path:String, viewFactory:Void->Component):Void;
    function navigate(path:String, ?params:Map<String, String>):Bool;
    function back():Void;
    function getCurrentPath():String;
    function getParam(name:String):Null<String>;
}