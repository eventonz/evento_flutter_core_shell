# API Documentation - Evento Core Flutter

This document outlines how the Evento Core Flutter application interacts with various APIs, including endpoints, expected variables, and error handling patterns.

## Base Configuration

### Primary API Base URL
- **Base URL**: `https://eventotracker.com`
- **API Path**: `/api/v3/api.cfm/`
- **Full Base URL**: `https://eventotracker.com/api/v3/api.cfm/`

### External Services
- **Assistant Service**: `https://eventochat.com` (configurable via `assistantBaseUrl`)
- **SportsSplits API**: `https://api.sportsplits.com/v2/`
- **YouTube API**: `https://www.youtube.com`

## API Handler Implementation

The application uses a centralized `ApiHandler` class (`lib/core/utils/api_handler.dart`) built on top of the Dio HTTP client library.

### Supported HTTP Methods
- `GET` - Retrieve data
- `POST` - Create/submit data
- `PUT` - Update data
- `PATCH` - Partial updates
- `DELETE` - Remove data

### Default Headers
```json
{
  "content-Type": "application/json"
}
```

### Timeout Configuration
- **Default POST timeout**: 10 seconds
- **Default GET timeout**: 30 seconds
- **Configurable per request**

## API Endpoints

### 1. Athletes Management

#### Get Athletes List
- **Endpoint**: `athletes/{raceId}`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/athletes/{raceId}`

**Request Body**:
```json
{
  "searchstring": "string",
  "pagenumber": 1,
  "include_country": true
}
```

**Expected Variables**:
- `raceId` (path parameter) - Event/race identifier
- `searchstring` - Search term for filtering athletes
- `pagenumber` - Page number for pagination
- `include_country` - Boolean flag to include country information

#### Get Athlete Details
- **Endpoint**: `athletes/{raceId}`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/athletes/{raceId}`

**Request Body**:
```json
{
  "searchstring": "string",
  "athlete_id": "string",
  "pagenumber": 1
}
```

**Expected Variables**:
- `raceId` (path parameter) - Event/race identifier
- `searchstring` - Search term
- `athlete_id` - Specific athlete identifier
- `pagenumber` - Page number

#### Follow/Unfollow Athlete
- **Endpoint**: `athletes/{raceId}`
- **Method**: `POST` (follow) / `DELETE` (unfollow)

**Request Body**:
```json
{
  "event_id": "string",
  "player_id": "string",
  "number": "string"
}
```

**Expected Variables**:
- `raceId` (path parameter) - Event/race identifier
- `event_id` - Event identifier
- `player_id` - OneSignal user ID
- `number` - Athlete number/bib

### 2. Athlete Tracking

#### Get Athlete Tracking Data
- **Endpoint**: `tracking`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/tracking`

**Request Body**:
```json
{
  "race_id": "string",
  "web_tracking": true,
  "tracks": ["athlete_id1", "athlete_id2"]
}
```

**Expected Variables**:
- `race_id` - Event/race identifier
- `web_tracking` - Boolean flag for web tracking
- `tracks` - Array of athlete IDs to track

### 3. Assistant/Chat Service

#### Get Assistant Configuration
- **Endpoint**: `api/assistants/{assistantId}/public-config`
- **Method**: `GET`
- **Base URL**: `https://eventochat.com` (configurable)

**Expected Variables**:
- `assistantId` (path parameter) - Assistant identifier

#### Send Chat Message
- **Endpoint**: `api/assistants/{assistantId}/chat`
- **Method**: `POST`
- **Base URL**: `https://eventochat.com` (configurable)

**Request Body**:
```json
{
  "message": "string",
  "messages": [],
  "source": "mobile"
}
```

**Expected Variables**:
- `assistantId` (path parameter) - Assistant identifier
- `message` - User message content
- `messages` - Chat history array
- `source` - Source identifier ("mobile")

#### Legacy Assistant Endpoint
- **Endpoint**: `assistant`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/assistant`

**Request Body**:
```json
{
  "request": "string",
  "race_id": "number",
  "player_id": "string"
}
```

### 4. App Installation Tracking

#### Track App Install
- **Endpoint**: `app_install`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/app_install`

**Request Body**:
```json
{
  "app_id": "string",
  "device_id": "string",
  "platform": "string",
  "app_version": "string",
  "os_version": "string",
  "device_model": "string"
}
```

### 5. Settings Management

#### Update Notification Settings
- **Endpoint**: `settings`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/settings`

**Request Body**:
```json
{
  "player_id": "string",
  "notifications": {
    "event": "boolean"
  }
}
```

### 6. Advertisement Tracking

#### Track Ad Interaction
- **Endpoint**: `adverts/{advertId}`
- **Method**: `POST`
- **URL**: `https://eventotracker.com/api/v3/api.cfm/adverts/{advertId}`

**Request Body**:
```json
{
  "action": "string"
}
```

### 7. SportsSplits Integration

#### Get Leaderboard Results
- **Endpoint**: `races/{raceId}/events/{eventId}/leaderboards/leaderboard/results/{filters}/{splitPath}`
- **Method**: `GET`
- **Base URL**: `https://api.sportsplits.com/v2/`

**Headers**:
```json
{
  "X-API-KEY": "BGE7FS8EY98DFAT57K7XL527F6CA58CJ"
}
```

**Query Parameters**:
- `page` - Page number
- `search` - Search term (optional)

#### Get Individual Results
- **Endpoint**: `races/{raceId}/results/individuals`
- **Method**: `GET`
- **Base URL**: `https://api.sportsplits.com/v2/`

**Query Parameters**:
- `search` - Search term

## Error Handling

### Error Handling Strategy

The application implements comprehensive error handling through the `ApiHandler` class:

#### 1. Exception Types Handled
- **DioException**: HTTP-related errors from the Dio client
- **TimeoutException**: Request timeout errors
- **Generic Exceptions**: Other unexpected errors

#### 2. Error Response Structure
All API methods return an `ApiData` object with:
```dart
class ApiData {
  final dynamic data;           // Response data or error details
  final int? statusCode;        // HTTP status code
  final String? statusMessage;  // Status message or error description
}
```

#### 3. Error Logging and Reporting
- **Logger Integration**: All requests and responses are logged using the application's Logger
- **Firebase Crashlytics**: Errors are automatically reported to Firebase Crashlytics with context:
  - URL that failed
  - Request data
  - Error response details
  - Stack trace

#### 4. Error Handling Pattern
```dart
try {
  // API call
  final response = await _dio.post(url, data: body);
  return ApiData(
    data: response.data,
    statusCode: response.statusCode,
    statusMessage: response.statusMessage
  );
} on DioException catch (e) {
  // Log error
  Logger.e('POST Error for $url: ${e.response?.data ?? e.message}');
  
  // Report to Crashlytics
  FirebaseCrashlytics.instance.recordError(e, e.stackTrace, reason: {
    'url': url,
    'data': body,
    'error': e.response?.data ?? e.response?.statusMessage ?? ''
  });
  
  // Return error response
  return ApiData(
    data: e.response?.data ?? {},
    statusCode: e.response?.statusCode ?? 500,
    statusMessage: e.response?.statusMessage ?? 'Error'
  );
}
```

#### 5. Timeout Handling
- **Default timeouts**: 10 seconds for POST, 30 seconds for GET
- **Configurable timeouts**: Can be overridden per request
- **TimeoutException**: Caught separately and returns 500 status code

#### 6. User-Facing Error Handling
- **Toast Messages**: User-friendly error messages displayed via `ToastUtils.show()`
- **Loading States**: UI loading states are managed through reactive variables
- **Fallback Data**: Default/empty data structures returned on errors

### Common Error Scenarios

1. **Network Connectivity Issues**
   - Handled by DioException
   - Returns 500 status code
   - Logged and reported to Crashlytics

2. **Server Errors (5xx)**
   - Caught by DioException
   - Original status code preserved
   - Error details logged

3. **Client Errors (4xx)**
   - Caught by DioException
   - Original status code preserved
   - May trigger specific UI responses

4. **Request Timeouts**
   - Caught by TimeoutException
   - Returns 500 status code
   - Separate logging for timeout events

5. **Invalid Response Format**
   - Handled at the model parsing level
   - May cause application-level exceptions
   - Logged with context

## Configuration

### App Configuration
The application supports multiple configuration modes:

1. **Single Event Mode**:
   ```dart
   AppEventConfig(
     singleEventUrl: 'https://eventotracker.com/api/v3/api.cfm/config',
     singleEventId: '121',
     appId: 40
   )
   ```

2. **Multi-Event Mode**:
   ```dart
   AppEventConfig(
     multiEventListUrl: 'https://eventotracker.com/api/v3/api.cfm/events',
     multiEventListId: '38',
     appId: 38
   )
   ```

### Environment-Specific URLs
- **Production**: `https://eventotracker.com`
- **Assistant Service**: `https://eventochat.com` (configurable)
- **SportsSplits**: `https://api.sportsplits.com/v2/`

## Security Considerations

1. **API Keys**: SportsSplits API key is hardcoded in the application
2. **User Identification**: Uses OneSignal user IDs for tracking
3. **Data Validation**: Input sanitization implemented for chat messages
4. **Error Reporting**: Sensitive data is filtered in error reports

## Dependencies

- **Dio**: HTTP client library
- **Firebase Crashlytics**: Error reporting
- **OneSignal**: User identification and push notifications
- **Logger**: Application logging system
