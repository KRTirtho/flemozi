import 'package:flemozi/collections/env.dart';
import 'package:flemozi/services/tenor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final tenorProvider = Provider((ref) => Tenor(apiKey: Env.tenor));
