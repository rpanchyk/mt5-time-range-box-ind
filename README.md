# Forex Time Range Box Indicator for MT5
Indicator shows user defined ranges in MetaTrader 5.

## Installation
- Open data folder in MetaTrader from menu `File -> Open Data Folder`.
- Copy [TimeRangeBox.mq5](MQL5/Indicators/TimeRangeBox.mq5) file to `<METATRADER_DATA_DIR>\MQL5\Indicators` folder.
- Update the list of indicators on Navigator panel.
- Drag `TimeRangeBox` indicator on the chart.

## Configuration
Available settings of the indicator:

![docs](docs/config.png)

Time ranges defined in format:
```
[HOUR:MIN]_[HOUR:MIN]_[COLOR],[HOUR:MIN]_[HOUR:MIN]_[COLOR]
```
Each range is separate by comma (`,`). There are limit on count of ranges.

For example:
```
23:00_08:00_clrLightGray,07:00_16:00_clrLightGreen
```

Color names can be found on official [MQL5 documentation](https://www.mql5.com/en/docs/constants/objectconstants/webcolors) page.

## Usage
Make a trade decision using the indicator:

![docs](docs/view.png)

## Contribution
Feel free to create an issue or a pull request if any ideas.

## Disclaimer
The source code of this repository is provided AS-IS and WITH NO WARRANTY of any kind.
Author and/or contributor are NOT responsilble for any type of losses as a result of using source code, 
compiled binaries or other outcomes related to this repository.
