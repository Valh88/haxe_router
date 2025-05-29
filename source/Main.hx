import haxe.ui.Toolkit;
import haxe_router.IRouter;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe_router.Factory.RouterFactory;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;
class Main {
    public static function main() {
        // Example use route
        Toolkit.init();

        var rootView = new VBox();
        rootView.percentWidth = rootView.percentHeight = 100;
        

        var router = RouterFactory.create(rootView);
        setupRoutes(router);
        
  
        Screen.instance.addComponent(rootView);
        

        router.navigate("/products");
    }
    
    private static function setupRoutes(router:IRouter):Void {
        router.addRoute("/", () -> {
            var view = new HBox();
            return view;
        });
        
        router.addRoute("/products", () -> {
            var view = new Label();
            return view;
        });
    }
}