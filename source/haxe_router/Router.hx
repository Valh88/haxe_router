package haxe_router;

import haxe.ui.core.Component;

class Router extends ARouter
{
	private var _routes:Map<String, Void->Component> = [];
	private var _currentView:Null<Component> = null;
	private var _rootContainer:Component;
	private var _history:Array<String> = [];
	private var _currentParams:Map<String, String> = new Map();

	public function new(rootContainer:Component)
	{
		_rootContainer = rootContainer;
		_initPlatformSpecific();
	}

	function _initPlatformSpecific():Void
	{
		#if js
		js.Browser.window.onpopstate = function(e)
		{
			_handleBrowserBack();
		};
		#end
	}

	public function addRoute(path:String, viewFactory:Void->Component):Void
	{
		_routes[path] = viewFactory;
	}

	public function navigate(path:String, ?params:Map<String, String>):Bool
	{
		var parsed = _parseUrl(path);
		var routePath = _findMatchingRoute(parsed.path);
		var pathParams = _extractPathParams(routePath, parsed.path);
		var queryParams = parsed.params;

		if (routePath == null)
		{
			return false;
		}

		var allParams = new Map<String, String>();
		var queryOnlyParams = new Map<String, String>();

		for (k in pathParams.keys())
		{
			allParams[k] = pathParams[k];
		}

		for (k in queryParams.keys())
		{
			allParams[k] = queryParams[k];
			queryOnlyParams[k] = queryParams[k];
		}

		if (params != null)
		{
			for (k in params.keys())
			{
				allParams[k] = params[k];
				queryOnlyParams[k] = params[k];
			}
		}

		if (_currentView != null)
		{
			_rootContainer.removeComponent(_currentView);
		}

		_currentView = _routes[routePath]();
		_currentParams = allParams;
		_injectParams(_currentView, allParams);

		// _rootContainer.addComponent(_currentView);
		var insertIndex = _rootContainer.numComponents - 1;
		if (insertIndex < 0) insertIndex = 0;
		_rootContainer.addComponentAt(_currentView, insertIndex);
		
		var fullUrl = path;
		if (queryOnlyParams.keys().hasNext())
		{
			var queryParts = [];
			for (key in queryOnlyParams.keys())
			{
				queryParts.push('${StringTools.urlEncode(key)}=${StringTools.urlEncode(queryOnlyParams.get(key))}');
			}
			fullUrl += "?" + queryParts.join("&");
		}
		
		_history.push(fullUrl);
		_updatePlatformHistory(path, queryOnlyParams);

		return true;
	}

	function _findMatchingRoute(path:String):Null<String>
	{
		if (_routes.exists(path))
		{
			return path;
		}

		for (route in _routes.keys())
		{
			if (route.indexOf(":") > -1)
			{
				var pattern = new EReg("^" + route.split("/").map(function(part)
				{
					return part.charAt(0) == ":" ? "([^/]+)" : part;
				}).join("/") + "$", "");

				if (pattern.match(path))
				{
					return route;
				}
			}
		}

		return null;
	}

	function _extractPathParams(route:String, path:String):Map<String, String>
	{
		var params = new Map<String, String>();

		if (route == null)
			return params;

		var routeParts = route.split("/");
		var pathParts = path.split("/");

		if (routeParts.length != pathParts.length)
			return params;

		for (i in 0...routeParts.length)
		{
			var routePart = routeParts[i];
			if (routePart.charAt(0) == ":")
			{
				var paramName = routePart.substr(1);
				params.set(paramName, pathParts[i]);
			}
		}

		return params;
	}

	public function back():Void
	{
		if (_history.length > 1)
		{
			_history.pop();
			var prevPath = _history.pop();
			navigate(prevPath);
		}
	}

	public function getCurrentPath():String
	{
		return _history.length > 0 ? _history[_history.length - 1] : "";
	}

	public function getParam(name:String):Null<String>
	{
		return _currentParams.get(name);
	}

	public function setParams(params:Map<String, String>):Void
	{
		_currentParams = params;
		if (_currentView != null)
		{
			_injectParams(_currentView, params);
		}
	}

	function _updatePlatformHistory(path:String, ?params:Map<String, String>):Void
	{
		#if js
        var state:Dynamic = {params: params};
    
        var url = path;
        if (params != null) {
            var queryParts = [];
            for (key in params.keys()) {
                if (path.indexOf(':$key') == -1) {
                    queryParts.push('${StringTools.urlEncode(key)}=${StringTools.urlEncode(params.get(key))}');
                }
            }
            if (queryParts.length > 0) {
                url += "?" + queryParts.join("&");
            }
        }
        
        js.Browser.window.history.pushState(state, '', url);
		#elseif android
		#elseif ios
		#end
	}

	function _handleBrowserBack():Void
	{
		#if js
		var path = js.Browser.window.location.pathname;
		var params = _parseQueryParams();
		navigate(path, params);
		#end
	}

	function _parseUrl(url:String):{path:String, params:Map<String, String>}
	{
		var result = {path: url, params: new Map<String, String>()};

		var parts = url.split("?");
		result.path = parts[0];

		if (parts.length > 1)
		{
			var query = parts[1];
			for (pair in query.split("&"))
			{
				var kv = pair.split("=");
				if (kv.length == 2)
				{
					var key = StringTools.urlDecode(kv[0]);
					var value = StringTools.urlDecode(kv[1]);
					result.params.set(key, value);
				}
			}
		}

		return result;
	}

	function _parseQueryParams():Map<String, String>
	{
		var params = new Map<String, String>();

		#if js
		var query = js.Browser.window.location.search.substring(1);
		if (query.length > 0)
		{
			for (pair in query.split("&"))
			{
				var kv = pair.split("=");
				if (kv.length == 2)
				{
					var key = StringTools.urlDecode(kv[0]);
					var value = StringTools.urlDecode(kv[1]);
					params.set(key, value);
				}
			}
		}
		#end

		return params;
	}

	function _injectParams(component:Component, params:Map<String, String>):Void
	{
		if (Std.isOfType(component, IParameterImplement))
		{
			var paramComponent:IParameterImplement = cast component;
			paramComponent.setParams(params);
		}
	}
}
