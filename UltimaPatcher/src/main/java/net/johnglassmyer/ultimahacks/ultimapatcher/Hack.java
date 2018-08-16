package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.util.Optional;

import com.google.common.collect.ImmutableList;
import com.google.protobuf.StringValue;
import com.google.protobuf.UInt32Value;

import net.johnglassmyer.ultimahacks.proto.HackProto;

class Hack {
	static Hack fromProtoHack(HackProto.Hack protoHack) {
		ImmutableList<Edit> edits = protoHack.getEditList().stream()
				.map(protoEdit -> CopyEdit.fromProtoEdit(protoEdit)
						.or(() -> InsertEdit.fromProtoEdit(protoEdit))
						.or(() -> OverwriteEdit.fromProtoEdit(protoEdit))
						.orElseThrow(() -> new RuntimeException("unexpected edit: " + protoEdit)))
				.collect(ImmutableList.toImmutableList());

		Optional<Integer> targetLength = protoHack.hasTargetLength()
				? Optional.of(protoHack.getTargetLength().getValue())
				: Optional.empty();

		Optional<String> comment = protoHack.hasComment()
				? Optional.of(protoHack.getComment().getValue())
				: Optional.empty();

		return new Hack(edits, targetLength, comment);
	}

	final ImmutableList<Edit> edits;
	final Optional<Integer> targetLength;
	final Optional<String> comment;

	Hack(ImmutableList<Edit> edits, Optional<Integer> targetLength, Optional<String> comment) {
		this.edits = edits;
		this.targetLength = targetLength;
		this.comment = comment;
	}

	HackProto.Hack toProtoHack() {
		HackProto.Hack.Builder hackBuilder = HackProto.Hack.newBuilder();

		edits.stream()
				.map(Edit::toProtoMessage)
				.forEachOrdered(hackBuilder::addEdit);

		targetLength.ifPresent(value -> hackBuilder.setTargetLength(UInt32Value.of(value)));

		comment.ifPresent(value -> hackBuilder.setComment(StringValue.of(value)));

		return hackBuilder.build();
	}
}
