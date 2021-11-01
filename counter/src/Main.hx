/*
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.layout.HorizontalLayout;

class Main extends Application {
	public function new() {
		super();
	}

	private var count:Int = 0;

	private var label:Label;
	private var button:Button;

	override private function initialize():Void {
		super.initialize();

		var layout = new HorizontalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 6.0;
		this.layout = layout;

		this.label = new Label();
		this.label.text = Std.string(this.count);
		this.label.width = 100.0;
		this.addChild(this.label);

		this.button = new Button();
		this.button.text = "Count";
		this.button.addEventListener(TriggerEvent.TRIGGER, button_triggerHandler);
		this.addChild(this.button);
	}

	private function button_triggerHandler(event:TriggerEvent):Void {
		this.count++;
		this.label.text = Std.string(this.count);
	}
}
