import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weathertracker/features/location/presentation/bloc/location_bloc.dart';
import 'package:weathertracker/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:weathertracker/features/weather/presentation/pages/home_page.dart';
import 'package:weathertracker/core/widgets/loading_widget.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([LocationBloc, WeatherBloc])
void main() {
  late MockLocationBloc mockLocationBloc;
  late MockWeatherBloc mockWeatherBloc;

  setUp(() {
    mockLocationBloc = MockLocationBloc();
    mockWeatherBloc = MockWeatherBloc();
  });

  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>.value(value: mockLocationBloc),
        BlocProvider<WeatherBloc>.value(value: mockWeatherBloc),
      ],
      child: const MaterialApp(
        home: HomePage(),
      ),
    );
  }

  testWidgets('should display loading widget when location state is initial', (widgetTester) async {

    when(mockLocationBloc.state).thenReturn(LocationInitial());
    when(mockWeatherBloc.state).thenReturn(WeatherInitial());
    when(mockLocationBloc.stream).thenAnswer((_) => const Stream.empty());
    when(mockWeatherBloc.stream).thenAnswer((_) => const Stream.empty());


    await widgetTester.pumpWidget(createWidgetUnderTest());

    //assert
    expect(find.byType(LoadingWidget), findsOneWidget);
  });
} 