import 'date_format.dart';
import 'datetime_util.dart';
import 'i18n_model.dart';

//interface for picker data model
abstract class BasePickerModel {
  //a getter method for left column data, return null to end list
  String? leftStringAtIndex(int index);

  //a getter method for middle column data, return null to end list
  String? middleStringAtIndex(int index);

  //a getter method for right column data, return null to end list
  String? rightStringAtIndex(int index);

  //set selected left index
  void setLeftIndex(int index);

  //set selected middle index
  void setMiddleIndex(int index);

  //set selected right index
  void setRightIndex(int index);

  //return current left index
  int currentLeftIndex();

  //return current middle index
  int currentMiddleIndex();

  //return current right index
  int currentRightIndex();

  //return final time
  DateTime? finalTime();

  //return left divider string
  String leftDivider();

  //return right divider string
  String rightDivider();

  //layout proportions for 3 columns
  List<int> layoutProportions();
}

//a base class for picker data model
class CommonPickerModel extends BasePickerModel {
  late List<String> leftList;
  late List<String> middleList;
  late List<String> rightList;
  late DateTime currentTime;
  late int _currentLeftIndex;
  late int _currentMiddleIndex;
  late int _currentRightIndex;

  late LocaleType locale;

  CommonPickerModel({LocaleType? locale}) : locale = locale ?? LocaleType.en;

  @override
  String? leftStringAtIndex(int index) {
    return null;
  }

  @override
  String? middleStringAtIndex(int index) {
    return null;
  }

  @override
  String? rightStringAtIndex(int index) {
    return null;
  }

  @override
  int currentLeftIndex() {
    return _currentLeftIndex;
  }

  @override
  int currentMiddleIndex() {
    return _currentMiddleIndex;
  }

  @override
  int currentRightIndex() {
    return _currentRightIndex;
  }

  @override
  void setLeftIndex(int index) {
    _currentLeftIndex = index;
  }

  @override
  void setMiddleIndex(int index) {
    _currentMiddleIndex = index;
  }

  @override
  void setRightIndex(int index) {
    _currentRightIndex = index;
  }

  @override
  String leftDivider() {
    return "";
  }

  @override
  String rightDivider() {
    return "";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime? finalTime() {
    return null;
  }
}

//a date picker model
class DatePickerModel extends CommonPickerModel {
  late DateTime maxTime;
  late DateTime minTime;

  DatePickerModel({
    DateTime? currentTime,
    DateTime? maxTime,
    DateTime? minTime,
    super.locale,
  }) {
    this.maxTime = maxTime ?? DateTime(2049, 12, 31);
    this.minTime = minTime ?? DateTime(1970, 1, 1);

    currentTime = currentTime ?? DateTime.now();

    if (currentTime.compareTo(this.maxTime) > 0) {
      currentTime = this.maxTime;
    } else if (currentTime.compareTo(this.minTime) < 0) {
      currentTime = this.minTime;
    }

    this.currentTime = currentTime;

    _fillLeftLists();
    _fillMiddleLists();
    _fillRightLists();
    int minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentLeftIndex = this.currentTime.year - this.minTime.year;
    _currentMiddleIndex = this.currentTime.month - minMonth;
    _currentRightIndex = this.currentTime.day - minDay;
  }

  void _fillLeftLists() {
    leftList = List.generate(maxTime.year - minTime.year + 1, (int index) {
      // print('LEFT LIST... ${minTime.year + index}${_localeYear()}');
      return '${minTime.year + index}${_localeYear()}';
    });
  }

  int _maxMonthOfCurrentYear() {
    return currentTime.year == maxTime.year ? maxTime.month : 12;
  }

  int _minMonthOfCurrentYear() {
    return currentTime.year == minTime.year ? minTime.month : 1;
  }

  int _maxDayOfCurrentMonth() {
    int dayCount = calcDateCount(currentTime.year, currentTime.month);
    return currentTime.year == maxTime.year &&
            currentTime.month == maxTime.month
        ? maxTime.day
        : dayCount;
  }

  int _minDayOfCurrentMonth() {
    return currentTime.year == minTime.year &&
            currentTime.month == minTime.month
        ? minTime.day
        : 1;
  }

  void _fillMiddleLists() {
    int minMonth = _minMonthOfCurrentYear();
    int maxMonth = _maxMonthOfCurrentYear();

    middleList = List.generate(maxMonth - minMonth + 1, (int index) {
      return _localeMonth(minMonth + index);
    });
  }

  void _fillRightLists() {
    int maxDay = _maxDayOfCurrentMonth();
    int minDay = _minDayOfCurrentMonth();
    rightList = List.generate(maxDay - minDay + 1, (int index) {
      return '${minDay + index}${_localeDay()}';
    });
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    //adjust middle
    int destYear = index + minTime.year;
    int minMonth = _minMonthOfCurrentYear();
    DateTime newTime;
    //change date time
    if (currentTime.month == 2 && currentTime.day == 29) {
      newTime = currentTime.isUtc
          ? DateTime.utc(
              destYear,
              currentTime.month,
              calcDateCount(destYear, 2),
            )
          : DateTime(destYear, currentTime.month, calcDateCount(destYear, 2));
    } else {
      newTime = currentTime.isUtc
          ? DateTime.utc(destYear, currentTime.month, currentTime.day)
          : DateTime(destYear, currentTime.month, currentTime.day);
    }
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillMiddleLists();
    _fillRightLists();
    minMonth = _minMonthOfCurrentYear();
    int minDay = _minDayOfCurrentMonth();
    _currentMiddleIndex = currentTime.month - minMonth;
    _currentRightIndex = currentTime.day - minDay;
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    //adjust right
    int minMonth = _minMonthOfCurrentYear();
    int destMonth = minMonth + index;
    DateTime newTime;
    //change date time
    int dayCount = calcDateCount(currentTime.year, destMonth);
    newTime = currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          )
        : DateTime(
            currentTime.year,
            destMonth,
            currentTime.day <= dayCount ? currentTime.day : dayCount,
          );
    //min/max check
    if (newTime.isAfter(maxTime)) {
      currentTime = maxTime;
    } else if (newTime.isBefore(minTime)) {
      currentTime = minTime;
    } else {
      currentTime = newTime;
    }

    _fillRightLists();
    int minDay = _minDayOfCurrentMonth();
    _currentRightIndex = currentTime.day - minDay;
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    int minDay = _minDayOfCurrentMonth();
    currentTime = currentTime.isUtc
        ? DateTime.utc(currentTime.year, currentTime.month, minDay + index)
        : DateTime(currentTime.year, currentTime.month, minDay + index);
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < leftList.length) {
      return leftList[index];
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < middleList.length) {
      return middleList[index];
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < rightList.length) {
      return rightList[index];
    } else {
      return null;
    }
  }

  String _localeYear() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '年';
    } else if (locale == LocaleType.ko) {
      return '년';
    } else {
      return '';
    }
  }

  String _localeMonth(int month) {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '$month月';
    } else if (locale == LocaleType.ko) {
      return '$month월';
    } else {
      List monthStrings = i18nObjInLocale(locale)['monthLong'] as List<String>;
      return monthStrings[month - 1];
    }
  }

  String _localeDay() {
    if (locale == LocaleType.zh || locale == LocaleType.jp) {
      return '日';
    } else if (locale == LocaleType.ko) {
      return '일';
    } else {
      return '';
    }
  }

  @override
  DateTime finalTime() {
    return currentTime;
  }
}

//a time picker model
class TimePickerModel extends CommonPickerModel {
  bool showSecondsColumn;

  TimePickerModel({
    DateTime? currentTime,
    super.locale,
    this.showSecondsColumn = true,
  }) {
    this.currentTime = currentTime ?? DateTime.now();

    _currentLeftIndex = this.currentTime.hour;
    _currentMiddleIndex = this.currentTime.minute;
    _currentRightIndex = this.currentTime.second;
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 24) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    if (showSecondsColumn) {
      return ":";
    } else {
      return "";
    }
  }

  @override
  List<int> layoutProportions() {
    if (showSecondsColumn) {
      return [1, 1, 1];
    } else {
      return [1, 1, 0];
    }
  }

  @override
  DateTime finalTime() {
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            _currentLeftIndex,
            _currentMiddleIndex,
            _currentRightIndex,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            _currentLeftIndex,
            _currentMiddleIndex,
            _currentRightIndex,
          );
  }
}

//a time picker model
class Time12hPickerModel extends CommonPickerModel {
  Time12hPickerModel({DateTime? currentTime, super.locale}) {
    this.currentTime = currentTime ?? DateTime.now();

    _currentLeftIndex = this.currentTime.hour % 12;
    _currentMiddleIndex = this.currentTime.minute;
    _currentRightIndex = this.currentTime.hour < 12 ? 0 : 1;
  }

  @override
  String? leftStringAtIndex(int index) {
    if (index >= 0 && index < 12) {
      if (index == 0) {
        return digits(12, 2);
      } else {
        return digits(index, 2);
      }
    } else {
      return null;
    }
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index >= 0 && index < 60) {
      return digits(index, 2);
    } else {
      return null;
    }
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index == 0) {
      return i18nObjInLocale(locale)["am"] as String?;
    } else if (index == 1) {
      return i18nObjInLocale(locale)["pm"] as String?;
    } else {
      return null;
    }
  }

  @override
  String leftDivider() {
    return ":";
  }

  @override
  String rightDivider() {
    return ":";
  }

  @override
  List<int> layoutProportions() {
    return [1, 1, 1];
  }

  @override
  DateTime finalTime() {
    int hour = _currentLeftIndex + 12 * _currentRightIndex;
    return currentTime.isUtc
        ? DateTime.utc(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            hour,
            _currentMiddleIndex,
            0,
          )
        : DateTime(
            currentTime.year,
            currentTime.month,
            currentTime.day,
            hour,
            _currentMiddleIndex,
            0,
          );
  }
}

// a date&time picker model
class DateTimePickerModel extends CommonPickerModel {
  DateTime? maxTime;
  DateTime? minTime;

  DateTimePickerModel({
    DateTime? currentTime,
    DateTime? maxTime,
    DateTime? minTime,
    super.locale,
  }) {
    this.minTime = minTime;
    this.maxTime = maxTime;

    var now = currentTime ?? DateTime.now();

    // Clamp currentTime inside min/max
    if (this.minTime != null && now.isBefore(this.minTime!)) {
      now = this.minTime!;
    }
    if (this.maxTime != null && now.isAfter(this.maxTime!)) {
      now = this.maxTime!;
    }

    this.currentTime = now;

    _currentLeftIndex = 0;
    _currentMiddleIndex = now.hour;
    _currentRightIndex = now.minute;

    _clampToRange();
  }

  /// Proper calendar day comparison
  bool isAtSameDay(DateTime? d1, DateTime? d2) {
    if (d1 == null || d2 == null) return false;
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  /// Ensure hour/minute indexes stay inside valid range
  void _clampToRange() {
    DateTime selectedDay = currentTime.add(Duration(days: _currentLeftIndex));

    // MIN restriction
    if (minTime != null && isAtSameDay(minTime, selectedDay)) {
      if (_currentMiddleIndex < minTime!.hour) {
        _currentMiddleIndex = minTime!.hour;
        _currentRightIndex = minTime!.minute;
      }

      if (_currentMiddleIndex == minTime!.hour &&
          _currentRightIndex < minTime!.minute) {
        _currentRightIndex = minTime!.minute;
      }
    }

    // MAX restriction
    if (maxTime != null && isAtSameDay(maxTime, selectedDay)) {
      if (_currentMiddleIndex > maxTime!.hour) {
        _currentMiddleIndex = maxTime!.hour;
        _currentRightIndex = maxTime!.minute;
      }

      if (_currentMiddleIndex == maxTime!.hour &&
          _currentRightIndex > maxTime!.minute) {
        _currentRightIndex = maxTime!.minute;
      }
    }

    _currentMiddleIndex = _currentMiddleIndex.clamp(0, 23);
    _currentRightIndex = _currentRightIndex.clamp(0, 59);
  }

  @override
  void setLeftIndex(int index) {
    super.setLeftIndex(index);
    _clampToRange();
  }

  @override
  void setMiddleIndex(int index) {
    super.setMiddleIndex(index);
    _clampToRange();
  }

  @override
  void setRightIndex(int index) {
    super.setRightIndex(index);
    _clampToRange();
  }

  @override
  String? leftStringAtIndex(int index) {
    DateTime time = currentTime.add(Duration(days: index));

    if (minTime != null &&
        time.isBefore(DateTime(minTime!.year, minTime!.month, minTime!.day))) {
      return null;
    }

    if (maxTime != null &&
        time.isAfter(DateTime(maxTime!.year, maxTime!.month, maxTime!.day))) {
      return null;
    }

    return formatDate(time, [ymdw], locale);
  }

  @override
  String? middleStringAtIndex(int index) {
    if (index < 0 || index > 23) return null;

    DateTime selectedDay = currentTime.add(Duration(days: _currentLeftIndex));

    if (minTime != null && isAtSameDay(minTime, selectedDay)) {
      if (index < minTime!.hour) return null;
    }

    if (maxTime != null && isAtSameDay(maxTime, selectedDay)) {
      if (index > maxTime!.hour) return null;
    }

    return digits(index, 2);
  }

  @override
  String? rightStringAtIndex(int index) {
    if (index < 0 || index > 59) return null;

    DateTime selectedDay = currentTime.add(Duration(days: _currentLeftIndex));

    if (minTime != null &&
        isAtSameDay(minTime, selectedDay) &&
        _currentMiddleIndex == minTime!.hour) {
      if (index < minTime!.minute) return null;
    }

    if (maxTime != null &&
        isAtSameDay(maxTime, selectedDay) &&
        _currentMiddleIndex == maxTime!.hour) {
      if (index > maxTime!.minute) return null;
    }

    return digits(index, 2);
  }

  @override
  DateTime finalTime() {
    DateTime selectedDay = currentTime.add(Duration(days: _currentLeftIndex));

    DateTime result = DateTime(
      selectedDay.year,
      selectedDay.month,
      selectedDay.day,
      _currentMiddleIndex,
      _currentRightIndex,
    );

    if (minTime != null && result.isBefore(minTime!)) {
      return minTime!;
    }

    if (maxTime != null && result.isAfter(maxTime!)) {
      return maxTime!;
    }

    return result;
  }

  @override
  List<int> layoutProportions() => [4, 1, 1];

  @override
  String rightDivider() => ':';
}
