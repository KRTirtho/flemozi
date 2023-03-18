import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const uuid = Uuid();

ValueNotifier<T> useDebouncedState<T>(T initialValue,
    {Duration duration = const Duration(milliseconds: 500)}) {
  final valueNotifier = useValueNotifier<T>(initialValue);
  final value = useState<T>(initialValue);

  useEffect(() {
    final id = uuid.v4();
    valueNotifier.addListener(() {
      EasyDebounce.debounce(id, duration, () {
        value.value = valueNotifier.value;
      });
    });
    return () => EasyDebounce.cancel(id);
  }, [valueNotifier.value]);

  return valueNotifier;
}
