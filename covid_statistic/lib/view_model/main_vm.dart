import 'package:covid_statistic/model/covid_info.dart';
import 'package:covid_statistic/model/country_info.dart';
import 'package:covid_statistic/model/main_info.dart';
import 'package:covid_statistic/network/response/response.dart';
import 'package:rxdart/rxdart.dart';

import 'base_vm.dart';

class MainViewModel extends BaseViewModel {
  final BehaviorSubject<CovidStatsResponse> _statsResponse = BehaviorSubject();
  final BehaviorSubject<CovidInfo> _pandemicResponse = BehaviorSubject();
  final BehaviorSubject<bool> _refreshStats = BehaviorSubject();
  final BehaviorSubject<MainInfo> _mainInfo = BehaviorSubject();
  final BehaviorSubject<List<CountryPandemic>> _countryPandemic = BehaviorSubject();
  final BehaviorSubject<bool> _refreshCountryList = BehaviorSubject();

  MainViewModel() {
    mainInfoChanged(MainInfo.world);
  }

  Function(CovidStatsResponse) get statsResponse => _statsResponse.sink.add;
  Function(CovidInfo) get pandemicResponse => _pandemicResponse.sink.add;
  Function(bool) get onRefreshStats => _refreshStats.sink.add;
  Function(MainInfo) get mainInfoChanged => _mainInfo.sink.add;
  Function(List<CountryPandemic>) get countryPandemicChanged => _countryPandemic.sink.add;
  Function(bool) get onRefreshCountryList => _refreshCountryList.sink.add;

  Stream<CovidStatsResponse> get pandemicStatsStream => _statsResponse.stream;
  Stream<CovidInfo> get pandemicInfo => _pandemicResponse.stream;
  Stream<bool> get refreshStatsStream => _refreshStats.stream;
  Stream<MainInfo> get mainInfoStream => _mainInfo.stream;
  Stream<List<CountryPandemic>> get countryPandemicStream => _countryPandemic.stream;
  Stream<bool> get refreshCountryStream => _refreshCountryList.stream;

  MainInfo get mainInfoItem => _mainInfo.value;
  List<CountryPandemic> get countryPandemic => _countryPandemic.value;
  CovidStatsResponse get pandemicStats => _statsResponse.value;

  fetchedStatistic({bool updateOther = false}) async {
    onRefreshCountryList(true);

    repo.getWorldometersInfo().then((value) {

      if (updateOther) {
        if (mainInfoItem.isVN) {
          pandemicResponse(value.vietnamInfo());
        } else {
          pandemicResponse(value.worldInfo());
        }

        onRefreshStats(false);
      }

      statsResponse(value);
      onRefreshCountryList(false);

    }).catchError((error) {
      errorEvent(error);
      statsResponse(null);
    });
  }

  fetchedPandemicVN() {
    onRefreshStats(true);
    repo.getPandemicVN().then((value) {
      pandemicResponse(value);
      onRefreshStats(false);
    }).catchError((error) {
      errorEvent(error);
      onRefreshStats(false);
      pandemicResponse(null);
    });
  }

  fetchedPandemicWorld() {
    onRefreshStats(true);
    repo.getPandemicWorld().then((value) {
      pandemicResponse(value);
      onRefreshStats(false);
    }).catchError((error) {
      errorEvent(error);
      onRefreshStats(false);
      pandemicResponse(null);
    });
  }

  void getCountryPandemic() {
    repo.getCountryPandemic().then((value) {
      var data = value;
      data.sort((l, r) => r.cases.compareTo(l.cases));
      countryPandemicChanged(data.toList());
    }).catchError((e) {
      errorEvent(error);
      countryPandemicChanged([]);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _statsResponse.close();
    _pandemicResponse.close();
    _refreshStats.close();
    _mainInfo.close();
    _countryPandemic.close();
    _refreshCountryList.close();
  }
}