import feathers.events.TriggerEvent;
import openfl.events.Event;
import feathers.controls.HSlider;
import feathers.controls.Label;
import feathers.skins.CircleSkin;
import feathers.layout.VerticalLayout;
import feathers.controls.Button;
import feathers.controls.Panel;

class DiameterPanel extends Panel {
	public function new() {
		super();
	}

	public var circleX(default, set):Float;

	private function set_circleX(value:Float):Float {
		if (this.circleX == value) {
			return this.circleX;
		}
		this.circleX = value;
		this.setInvalid(DATA);
		return this.circleX;
	}

	public var circleY(default, set):Float;

	private function set_circleY(value:Float):Float {
		if (this.circleY == value) {
			return this.circleY;
		}
		this.circleY = value;
		this.setInvalid(DATA);
		return this.circleY;
	}

	public var diameter(default, set):Float;

	private function set_diameter(value:Float):Float {
		if (this.diameter == value) {
			return this.diameter;
		}
		this.diameter = value;
		this.setInvalid(DATA);
		return this.diameter;
	}

	private var circle:CircleSkin;
	private var messageLabel:Label;
	private var diameterSlider:HSlider;
	private var saveButton:Button;

	override public function initialize():Void {
		var panelLayout = new VerticalLayout();
		panelLayout.horizontalAlign = CENTER;
		panelLayout.setPadding(10.0);
		panelLayout.gap = 10.0;
		this.layout = panelLayout;

		this.messageLabel = new Label();
		this.addChild(this.messageLabel);

		this.diameterSlider = new HSlider();
		this.diameterSlider.minimum = 10.0;
		this.diameterSlider.maximum = 100.0;
		this.diameterSlider.value = this.diameter;
		this.diameterSlider.snapInterval = 1.0;
		this.diameterSlider.addEventListener(Event.CHANGE, diameterSlider_changeHandler);
		this.addChild(this.diameterSlider);

		this.saveButton = new Button();
		this.saveButton.text = "Save";
		this.saveButton.addEventListener(TriggerEvent.TRIGGER, saveButton_triggerHandler);
		this.addChild(this.saveButton);
	}

	override private function update():Void {
		this.messageLabel.text = 'Adjust diameter of circle at (${this.circleX} , ${this.circleY})';
		this.diameterSlider.value = this.diameter;

		super.update();
	}

	private function diameterSlider_changeHandler(event:Event):Void {
		this.diameter = this.diameterSlider.value;
	}

	private function saveButton_triggerHandler(event:TriggerEvent):Void {
		this.dispatchEvent(new Event(Event.COMPLETE));
	}
}
