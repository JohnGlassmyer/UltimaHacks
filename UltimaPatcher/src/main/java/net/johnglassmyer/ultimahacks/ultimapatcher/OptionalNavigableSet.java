package net.johnglassmyer.ultimahacks.ultimapatcher;

import java.util.NavigableSet;
import java.util.Optional;

import com.google.common.collect.ForwardingNavigableSet;

public class OptionalNavigableSet<E> extends ForwardingNavigableSet<E> {
	public static <E> OptionalNavigableSet<E> of(NavigableSet<E> set) {
		return new OptionalNavigableSet<>(set);
	}

	private final NavigableSet<E> delegate;

	private OptionalNavigableSet(NavigableSet<E> delegate) {
		this.delegate = delegate;
	}

	@Override
	protected NavigableSet<E> delegate() {
		return delegate;
	}

	public Optional<E> optionalHigher(E e) {
		return Optional.ofNullable(higher(e));
	}
}
