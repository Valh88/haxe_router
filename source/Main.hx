import haxe.ui.components.Button;
import haxe.ui.Toolkit;
import haxe_router.ARouter;
import haxe.ui.components.Label;
import haxe.ui.containers.HBox;
import haxe_router.Factory.RouterFactory;
import haxe.ui.containers.VBox;
import haxe.ui.core.Screen;

class Main
{
	public static function main()
	{
		// Example use route
		Toolkit.init();

		var rootView = new VBox();
		rootView.percentWidth = rootView.percentHeight = 100;

		var router = RouterFactory.create(rootView);
		setupRoutes(router);

		Screen.instance.addComponent(rootView);

		router.navigate("/");
	}

	private static function setupRoutes(router:ARouter):Void
	{
		router.addRoute("/", () ->
		{
			var view = new HBox();
			var button = new Button();
			button.text = "Go to products";
			button.onClick = function(e)
			{
				router.navigate("/products/123/huy?category=electronics&sort=price");
			};
			view.addComponent(button);
			return view;
		});

		router.addRoute("/products/:id/:huy", () ->
		{
			var view = new Label();
			return view;
		});
	}
}
