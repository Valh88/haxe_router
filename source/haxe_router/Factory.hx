package haxe_router;

import haxe.ui.core.Component;

class RouterFactory {
    public static function create(rootContainer:Component):IRouter {
        #if web
        return new WebRouter(rootContainer);
        #elseif mobile
        return new MobileRouter(rootContainer);
        #else
        return new Router(rootContainer);
        #end
    }
}


class WebRouter extends Router {
    //
}

class MobileRouter extends Router {
    // 
}