/*
	Copyright 2021 Bowler Hat LLC. All Rights Reserved.

	This program is free software. You can redistribute and/or modify it in
	accordance with the terms of the accompanying license agreement.
 */

import feathers.core.PopUpManager;
import feathers.controls.HSlider;
import feathers.controls.Header;
import feathers.controls.Panel;
import feathers.skins.CircleSkin;
import openfl.display.Sprite;
import openfl.events.MouseEvent;
import feathers.skins.RectangleSkin;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalLayout;
import feathers.events.TriggerEvent;
import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.Application;
import feathers.controls.Label;
import feathers.controls.TextInput;
import feathers.layout.HorizontalLayout;
import openfl.events.Event;

class Main extends Application {
	public function new() {
		super();
	}

	private var undoButton:Button;
	private var redoButton:Button;
	private var canvas:LayoutGroup;

	private var selectedCircleIndex:Int = -1;

	private var undoStack:Array<UndoAction> = [];
	private var redoStack:Array<UndoAction> = [];

	override private function initialize():Void {
		super.initialize();

		var appLayout = new VerticalLayout();
		appLayout.horizontalAlign = JUSTIFY;
		appLayout.setPadding(10.0);
		appLayout.gap = 10.0;
		this.layout = appLayout;

		var buttonLayout = new HorizontalLayout();
		buttonLayout.horizontalAlign = CENTER;
		buttonLayout.gap = 10.0;
		var buttonContainer = new LayoutGroup();
		buttonContainer.layout = buttonLayout;
		this.addChild(buttonContainer);

		this.undoButton = new Button();
		this.undoButton.text = "Undo";
		this.undoButton.addEventListener(TriggerEvent.TRIGGER, undoButton_triggerHandler);
		buttonContainer.addChild(this.undoButton);

		this.redoButton = new Button();
		this.redoButton.text = "Redo";
		this.redoButton.addEventListener(TriggerEvent.TRIGGER, redoButton_triggerHandler);
		buttonContainer.addChild(this.redoButton);

		this.canvas = new LayoutGroup();
		this.canvas.doubleClickEnabled = true;
		this.canvas.backgroundSkin = new RectangleSkin(SolidColor(0xffffff), SolidColor(1.0, 0x00000));
		this.canvas.layoutData = VerticalLayoutData.fillVertical();
		this.canvas.addEventListener(MouseEvent.CLICK, canvas_clickHandler);
		this.canvas.addEventListener(MouseEvent.RIGHT_CLICK, canvas_rightClickHandler);
		this.canvas.addEventListener(MouseEvent.DOUBLE_CLICK, canvas_doubleClickHandler);
		this.addChild(this.canvas);
	}

	private function addUndoAction(action:UndoAction):Void {
		this.undoStack.push(action);
		this.redoStack.resize(0);
	}

	private function createCircle(circleX:Float, circleY:Float):Void {
		var undo = () -> {
			var removeIndex = this.canvas.numChildren - 1;
			var circleToRemove = this.canvas.getChildAt(removeIndex);
			this.canvas.removeChild(circleToRemove);
			if (this.selectedCircleIndex == removeIndex) {
				this.selectedCircleIndex = -1;
				this.refreshSelection();
			}
		};
		var redo = () -> {
			var startDiameter = 10.0;
			var circle = new CircleSkin(SolidColor(0x999999), SolidColor(1.0, 0x000000));
			circle.doubleClickEnabled = true;
			circle.width = startDiameter;
			circle.height = startDiameter;
			circle.x = Std.int(circleX - (startDiameter / 2.0));
			circle.y = Std.int(circleY - (startDiameter / 2.0));
			this.canvas.addChild(circle);
			this.selectedCircleIndex = this.canvas.numChildren - 1;
			this.refreshSelection();
		}

		redo();

		this.addUndoAction(new UndoAction(undo, redo));
	}

	private function resizeCircle(newDiameter:Float):Void {
		var circleIndex = this.selectedCircleIndex;
		var circle = cast(this.canvas.getChildAt(circleIndex), CircleSkin);
		var oldDiameter = circle.width;
		if (oldDiameter == newDiameter) {
			// nothing to change
			return;
		}

		var circleX = circle.x + (oldDiameter / 2.0);
		var circleY = circle.y + (oldDiameter / 2.0);

		var undo = () -> {
			var circle = cast(this.canvas.getChildAt(circleIndex), CircleSkin);
			circle.width = oldDiameter;
			circle.height = oldDiameter;
			circle.x = circleX - (oldDiameter / 2.0);
			circle.y = circleY - (oldDiameter / 2.0);
			this.selectedCircleIndex = circleIndex;
			this.refreshSelection();
		}
		var redo = () -> {
			var circle = cast(this.canvas.getChildAt(circleIndex), CircleSkin);
			circle.width = newDiameter;
			circle.height = newDiameter;
			circle.x = circleX - (newDiameter / 2.0);
			circle.y = circleY - (newDiameter / 2.0);
			this.selectedCircleIndex = circleIndex;
			this.refreshSelection();
		}

		redo();

		this.addUndoAction(new UndoAction(undo, redo));
	}

	private function refreshSelection():Void {
		for (i in 0...this.canvas.numChildren) {
			var circle = cast(this.canvas.getChildAt(i), CircleSkin);
			if (this.selectedCircleIndex == i) {
				circle.fill = SolidColor(0x999999);
			} else {
				circle.fill = SolidColor(0xffffff);
			}
		}
	}

	private function showAdjustmentPanel():Void {
		var circle = cast(this.canvas.getChildAt(this.selectedCircleIndex), CircleSkin);
		var panel = new DiameterPanel();
		panel.circleX = Std.int(circle.x + (circle.width / 2.0));
		panel.circleY = Std.int(circle.y + (circle.height / 2.0));
		panel.diameter = Std.int(circle.width);
		panel.addEventListener(Event.COMPLETE, panel_completeHandler);
		PopUpManager.addPopUp(panel, this.canvas, true, true);
	}

	private function undoButton_triggerHandler(event:Event):Void {
		if (this.undoStack.length == 0) {
			return;
		}
		var action = this.undoStack.pop();
		action.undo();
		this.redoStack.push(action);
	}

	private function redoButton_triggerHandler(event:Event):Void {
		if (this.redoStack.length == 0) {
			return;
		}
		var action = this.redoStack.pop();
		action.redo();
		this.undoStack.push(action);
	}

	private function panel_completeHandler(event:Event):Void {
		var panel = cast(event.currentTarget, DiameterPanel);
		PopUpManager.removePopUp(panel);

		this.resizeCircle(panel.diameter);
	}

	private function canvas_clickHandler(event:MouseEvent):Void {
		var circle = Std.downcast(event.target, CircleSkin);
		var actionX = canvas.mouseX;
		var actionY = canvas.mouseY;
		if (circle == null) {
			this.createCircle(actionX, actionY);
		} else {
			this.selectedCircleIndex = this.canvas.getChildIndex(circle);
		}
		this.refreshSelection();
	}

	private function canvas_rightClickHandler(event:MouseEvent):Void {
		var circle = Std.downcast(event.target, CircleSkin);
		if (circle == null) {
			return;
		}
		var circleIndex = this.canvas.getChildIndex(circle);
		if (circleIndex != this.selectedCircleIndex) {
			return;
		}
		this.showAdjustmentPanel();
	}

	private function canvas_doubleClickHandler(event:MouseEvent):Void {
		var circle = Std.downcast(event.target, CircleSkin);
		if (circle == null) {
			return;
		}
		var circleIndex = this.canvas.getChildIndex(circle);
		if (circleIndex != this.selectedCircleIndex) {
			return;
		}
		this.showAdjustmentPanel();
	}
}
