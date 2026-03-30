import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker_app/core/cubit/auth_cubit.dart';
import 'package:expense_tracker_app/core/network/api_client.dart';
import 'package:expense_tracker_app/features/expense/data/datasources/expense_local_data_source.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockExpenseLocalDataSource extends Mock
    implements ExpenseLocalDataSource {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockApiClient mockApiClient;
  late MockExpenseLocalDataSource mockLocalDataSource;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockApiClient = MockApiClient();
    mockLocalDataSource = MockExpenseLocalDataSource();
    when(() => mockLocalDataSource.clearLocalCache())
        .thenAnswer((_) async {});
  });

  AuthCubit buildCubit() => AuthCubit(
        apiClient: mockApiClient,
        localDataSource: mockLocalDataSource,
      );

  // Helper to build a fake successful login response
  Response<dynamic> loginResponse({
    String email = 'test@example.com',
    String displayName = 'Test User',
  }) =>
      Response<dynamic>(
        data: {
          'data': {
            'email': email,
            'displayName': displayName,
          },
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/login'),
      );

  group('AuthCubit', () {
    group('initial state', () {
      test('is unauthenticated with no user', () {
        final cubit = buildCubit();
        expect(cubit.state.status, AuthStatus.unauthenticated);
        expect(cubit.state.username, isNull);
        expect(cubit.state.displayName, isNull);
        cubit.close();
      });
    });

    group('login', () {
      blocTest<AuthCubit, AuthState>(
        'returns false immediately for empty email',
        build: buildCubit,
        act: (cubit) => cubit.login(email: '', password: '123456'),
        verify: (cubit) {
          expect(cubit.state.status, AuthStatus.unauthenticated);
          verifyNever(
              () => mockApiClient.post(any(), data: any(named: 'data')));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits submitting then authenticated on success',
        setUp: () {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenAnswer((_) async => loginResponse());
        },
        build: buildCubit,
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: '123456'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.authenticated)
              .having((s) => s.username, 'username', 'test@example.com')
              .having((s) => s.isSubmitting, 'isSubmitting', isFalse),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits submitting then unauthenticated on failure',
        setUp: () {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              type: DioExceptionType.badResponse,
              response: Response(
                statusCode: 401,
                data: {'message': 'Invalid email or password'},
                requestOptions: RequestOptions(path: '/auth/login'),
              ),
            ),
          );
        },
        build: buildCubit,
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: 'wrongpass'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.isSubmitting, 'isSubmitting', isFalse),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'emits loginRequiresInternet error on connection error',
        setUp: () {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/auth/login'),
              type: DioExceptionType.connectionError,
            ),
          );
        },
        build: buildCubit,
        act: (cubit) =>
            cubit.login(email: 'test@example.com', password: '123456'),
        verify: (cubit) {
          expect(cubit.state.errorCode, AuthErrorCode.loginRequiresInternet);
        },
      );
    });

    group('register', () {
      blocTest<AuthCubit, AuthState>(
        'returns false immediately for empty email',
        build: buildCubit,
        act: (cubit) => cubit.register(email: '', password: '123456'),
        verify: (cubit) {
          verifyNever(
              () => mockApiClient.post(any(), data: any(named: 'data')));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'returns false for password shorter than 6 chars',
        build: buildCubit,
        act: (cubit) =>
            cubit.register(email: 'test@example.com', password: '123'),
        verify: (cubit) {
          verifyNever(
              () => mockApiClient.post(any(), data: any(named: 'data')));
        },
      );

      blocTest<AuthCubit, AuthState>(
        'emits submitting then unauthenticated on success',
        setUp: () {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenAnswer(
            (_) async => Response<dynamic>(
              data: {'data': {}},
              statusCode: 201,
              requestOptions: RequestOptions(path: '/auth/register'),
            ),
          );
        },
        build: buildCubit,
        act: (cubit) =>
            cubit.register(email: 'test@example.com', password: '123456'),
        expect: () => [
          isA<AuthState>()
              .having((s) => s.isSubmitting, 'isSubmitting', isTrue),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.isSubmitting, 'isSubmitting', isFalse),
        ],
      );

      blocTest<AuthCubit, AuthState>(
        'stores server message on register failure',
        setUp: () {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenThrow(
            DioException(
              requestOptions: RequestOptions(path: '/auth/register'),
              type: DioExceptionType.badResponse,
              response: Response<dynamic>(
                statusCode: 409,
                data: {'message': 'Email already registered'},
                requestOptions: RequestOptions(path: '/auth/register'),
              ),
              message: 'Email already registered',
            ),
          );
        },
        build: buildCubit,
        act: (cubit) =>
            cubit.register(email: 'test@example.com', password: '123456'),
        verify: (cubit) {
          expect(cubit.state.errorMessage, 'Email already registered');
          expect(cubit.state.isSubmitting, isFalse);
        },
      );
    });

    group('logout', () {
      blocTest<AuthCubit, AuthState>(
        'emits guest mode with cleared user data',
        setUp: () {
          when(() => mockApiClient.post(
                any(),
                data: any(named: 'data'),
              )).thenAnswer((_) async => loginResponse());
        },
        build: buildCubit,
        act: (cubit) async {
          await cubit.login(email: 'test@example.com', password: '123456');
          await cubit.logout();
        },
        verify: (cubit) {
          expect(cubit.state.status, AuthStatus.guest);
          expect(cubit.state.username, isNull);
          expect(cubit.state.displayName, isNull);
          verify(() => mockLocalDataSource.clearLocalCache()).called(2);
        },
      );
    });
  });
}
