import QtQuick 2.8
import QtQuick.Window 2.0
import QtGraphicalEffects 1.12
import QtQml 2.15
import QtQuick.Layouts 1.1
import "../../../js/enums.mjs" as Enums

import "../../../components"

ActionList {
  property var game

  focus: true
  model: ListModel {
    ListElement {
      label: () => "Start"
      action: () => game.launch()
      canExecute: () => true
    }
    ListElement {
      label: () => "Uninstall"
      action: () => game.launch()
      canExecute: () => false
    }
    //ListElement {
    //  label: () => "Watch Preview"
    //  action: () => navigate(pages.videoPlayer, { [Enums.MemoryKeys.VideoPath]: game.assets.video })
    //  canExecute: () => !!game.assets.video
    //}
    // ListElement {
    //   label: () => !game.favorite ? "Pin to Home" : "Remove Pin"
    //   action: () => game.favorite = !game.favorite
    //   canExecute: () => true
    // }
  }
}
