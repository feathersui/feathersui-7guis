class UndoAction {
	public function new(undo:() -> Void, redo:() -> Void) {
		this.undo = undo;
		this.redo = redo;
	}

	public var undo:() -> Void;
	public var redo:() -> Void;
}
