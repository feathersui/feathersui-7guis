/*
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import feathers.controls.Application;
import feathers.controls.Button;
import feathers.controls.HProgressBar;
import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.events.TriggerEvent;
import feathers.layout.VerticalLayout;
import openfl.Lib;
import openfl.events.Event;

class Main extends Application {
	public function new() {
		super();
	}

	private var active = false;
	private var startTime:Float;
	private var duration:Float = 0.0;
	private var elapsedTime:Float = 0.0;

	private var progress:HProgressBar;
	private var timeLabel:Label;
	private var durationSlider:HSlider;
	private var resetButton:Button;

	override private function initialize():Void {
		super.initialize();

		var layout = new VerticalLayout();
		layout.paddingTop = 10.0;
		layout.paddingRight = 10.0;
		layout.paddingBottom = 10.0;
		layout.paddingLeft = 10.0;
		layout.gap = 6.0;
		this.layout = layout;

		this.progress = new HProgressBar();
		this.progress.minimum = 0.0;
		this.progress.maximum = 1.0;
		this.progress.value = 0.0;
		this.addChild(this.progress);

		this.timeLabel = new Label();
		this.timeLabel.text = "0.0";
		this.addChild(this.timeLabel);

		this.durationSlider = new HSlider();
		this.durationSlider.minimum = 0.0;
		this.durationSlider.maximum = 15.0;
		this.durationSlider.value = 0.0;
		this.durationSlider.addEventListener(Event.CHANGE, durationSlider_changeHandler);
		this.addChild(this.durationSlider);

		this.resetButton = new Button();
		this.resetButton.text = "Reset";
		this.resetButton.addEventListener(TriggerEvent.TRIGGER, resetButton_triggerHandler);
		this.addChild(this.resetButton);

		this.refreshAll();
	}

	private function checkForStart():Void {
		if (!this.active && this.duration > this.elapsedTime) {
			this.startTime = (Lib.getTimer() / 1000.0) - this.elapsedTime;
			this.active = true;
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}

	private function checkForEnd():Void {
		if (this.elapsedTime >= this.duration) {
			active = false;
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}

	private function refreshAll():Void {
		this.progress.maximum = Math.max(this.duration, 1.0);
		this.progress.value = this.elapsedTime;

		var roundedElapsedTime = Math.round(this.elapsedTime * 10.0) / 10.0;
		var timeText = Std.string(roundedElapsedTime);
		if (timeText.indexOf(".") == -1) {
			timeText += ".0";
		}
		timeText += "s";
		this.timeLabel.text = timeText;
	}

	private function enterFrameHandler(event:Event):Void {
		this.elapsedTime = (Lib.getTimer() / 1000.0) - this.startTime;
		this.checkForEnd();
		this.refreshAll();
	}

	private function durationSlider_changeHandler(event:Event):Void {
		this.duration = this.durationSlider.value;
		this.checkForStart();
		this.checkForEnd();
		this.refreshAll();
	}

	private function resetButton_triggerHandler(event:TriggerEvent):Void {
		this.elapsedTime = 0.0;
		this.startTime = Lib.getTimer() / 1000.0;

		this.checkForStart();
		this.refreshAll();
	}
}
