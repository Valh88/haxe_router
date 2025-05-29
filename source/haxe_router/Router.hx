package haxe_router;

import haxe.ui.core.Component;

class Router implements IRouter {
    private var _routes:Map<String, Void->Component> = [];
    private var _currentView:Null<Component> = null;
    private var _rootContainer:Component;
    private var _history:Array<String> = [];
    
    public function new(rootContainer:Component) {
        _rootContainer = rootContainer;
        initPlatformSpecific();
    }
    
    private function initPlatformSpecific():Void {
        #if js
        js.Browser.window.onpopstate = function(e) {
            handleBrowserBack();
        };
        #end
    }
    
    public function addRoute(path:String, viewFactory:Void->Component):Void {
        _routes[path] = viewFactory;
    }
    
    public function navigate(path:String, ?params:Map<String, String>):Bool {
        if (!_routes.exists(path)) {
            return false;
        }
        
        if (_currentView != null) {
            _rootContainer.removeComponent(_currentView);
        }
        
        _currentView = _routes[path]();
        _rootContainer.addComponent(_currentView);
        trace(_currentView);
        _history.push(path);
        updatePlatformHistory(path, params);
        
        return true;
    }
    
    public function back():Void {
        if (_history.length > 1) {
            _history.pop(); 
            var prevPath = _history.pop();
            navigate(prevPath);
        }
    }
    
    public function getCurrentPath():String {
        return _history.length > 0 ? _history[_history.length - 1] : "";
    }
    
    public function getParam(name:String):Null<String> {
        return null;
    }
    
    private function updatePlatformHistory(path:String, ?params:Map<String, String>):Void {
        #if js
        var state:Dynamic = { params: params };
        js.Browser.window.history.pushState(state, '', path);
        #elseif android
      
        #elseif ios
 
        #end
    }
    
    private function handleBrowserBack():Void {
        #if js
        var path = js.Browser.window.location.pathname;
        if (_routes.exists(path)) {
            navigate(path);
        }
        #end
    }
}