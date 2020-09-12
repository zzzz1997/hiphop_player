import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/global.dart';
import '../model/locale.dart';
import '../model/theme.dart';

///
/// 设置页面
///
/// @author zzzz1997
/// @created_time 20200116
///
class SettingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Global.s.setting),
      ),
      body: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.symmetric(
            horizontal: 30,
          ),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ExpansionTile(
                  title: Text(Global.s.colorTheme),
                  leading: Icon(
                    Icons.color_lens,
                    color: Theme.of(context).accentColor,
                  ),
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        children: <Widget>[
                          ...Colors.primaries
                              .map((color) => Material(
                            color: color,
                            child: InkWell(
                              onTap: () {
                                Provider.of<ThemeModel>(context,
                                    listen: false)
                                    .switchTheme(color: color);
                              },
                              child: SizedBox(
                                width: 40,
                                height: 40,
                              ),
                            ),
                          ))
                              .toList(),
                          Material(
                            child: InkWell(
                              onTap: () {
                                Provider.of<ThemeModel>(context, listen: false)
                                    .switchRandomTheme();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                                width: 40,
                                height: 40,
                                child: Text(
                                  '?',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Theme.of(context).accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(Global.s.font),
                      ),
                      Text(
                        ThemeModel.fontName(
                            Provider.of<ThemeModel>(context, listen: false)
                                .fontIndex),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.font_download,
                    color: Theme.of(context).accentColor,
                  ),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        var model =
                        Provider.of<ThemeModel>(context, listen: false);
                        return RadioListTile(
                          value: i,
                          groupValue: model.fontIndex,
                          onChanged: (i) {
                            model.switchFont(i);
                          },
                          title: Text(ThemeModel.fontName(i)),
                        );
                      },
                      itemCount: ThemeModel.fontValueList.length,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Material(
                color: Theme.of(context).cardColor,
                child: ExpansionTile(
                  title: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(Global.s.language),
                      ),
                      Text(
                        LocaleModel.localeName(
                            Provider.of<LocaleModel>(context).localeIndex),
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                  leading: Icon(
                    Icons.public,
                    color: Theme.of(context).accentColor,
                  ),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        var model = Provider.of<LocaleModel>(context);
                        return RadioListTile(
                          value: i,
                          groupValue: model.localeIndex,
                          onChanged: (i) {
                            model.switchLocale(i);
                          },
                          title: Text(LocaleModel.localeName(i)),
                        );
                      },
                      itemCount: LocaleModel.localeValueList.length,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
