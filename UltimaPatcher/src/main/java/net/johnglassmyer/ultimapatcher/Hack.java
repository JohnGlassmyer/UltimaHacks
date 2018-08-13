package net.johnglassmyer.ultimapatcher;

import com.google.common.collect.ImmutableList;

import net.johnglassmyer.ultimahacks.common.HackProto;

class Hack {
	static Hack fromProtoHack(HackProto.Hack protoHack) {
		ImmutableList<Edit> edits = protoHack.getEditList().stream()
				.map(protoEdit -> CopyEdit.fromProtoEdit(protoEdit)
						.or(() -> InsertEdit.fromProtoEdit(protoEdit))
						.or(() -> OverwriteEdit.fromProtoEdit(protoEdit))
						.orElseThrow(() -> new RuntimeException("unexpected edit: " + protoEdit)))
				.collect(ImmutableList.toImmutableList());

		return new Hack(edits);
	}

	final ImmutableList<Edit> edits;

	private Hack(ImmutableList<Edit> edits) {
		this.edits = edits;
	}
}
