import QtQuick 2.8
import QtQuick.Window 2.0
import QtGraphicalEffects 1.0
import "../../components"
import "../../js/styling.mjs" as Styling
import "../../js/enums.mjs" as Enums

Item {
  focus: true

  Component {
    id: sectionDelegate
    StyledText {
      id: sectionName
      anchors.left: parent.left
      horizontalAlignment: Text.AlignLeft
      opacity: PathView.itemOpacity
      z: index
      text: name
      font.pixelSize: vpx(41)
      transform:[
        Translate {
          y: -sectionName.height * (1 - sectionName.PathView.itemOpacity)
        },
        Scale {
          xScale: sectionName.PathView.itemScale
          yScale: sectionName.PathView.itemScale
        }
      ]
    }
  }

  property var currentPlatform: api.collections.get(platformsList.currentIndex)
  property var currentGame: currentPlatform.games.get(gamesList.currentIndex)

  Keys.onUpPressed: {
    if (!event.isAutoRepeat) platformsList.incrementCurrentIndex()
  }

  Keys.onDownPressed: {
    if (!event.isAutoRepeat) platformsList.decrementCurrentIndex()
  }

  Keys.onLeftPressed: {
    if (!event.isAutoRepeat) gamesList.previousItem()
  }

  Keys.onRightPressed: {
    if (!event.isAutoRepeat) gamesList.nextItem()
  }

  Keys.onPressed: {
    if (!event.isAutoRepeat) {
      if (api.keys.isAccept(event)) {
        currentGame.launch();
      } else if (api.keys.isNextPage(event)) {
        gamesList.navigateForwardQuickly();
      } else if (api.keys.isPrevPage(event)) {
        gamesList.navigateBackwardsQuickly();
      } else if (api.keys.isDetails(event)) {
        navigate(pages.gameDetails, { [Enums.MemoryKeys.CurrentGame]: currentGame });
      }
    }
  }

  PathView {
    id: platformsList
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    anchors.leftMargin: vpx(92)
    anchors.topMargin: vpx(74)
    height: vpx(149)
    model: api.collections
    delegate: sectionDelegate
    pathItemCount: 5
    property int previousIndex: 0

    preferredHighlightBegin: height - vpx(60)
    preferredHighlightEnd: height - vpx(30)

    path: Path {
      startX: 0; startY: platformsList.height - 21
      PathAttribute { name: "itemScale"; value: 1 }
      PathAttribute { name: "itemOpacity"; value: 1 }

      PathLine { x: 0; y: vpx(30) }
      PathAttribute { name: "itemScale"; value: 0.39 }
      PathAttribute { name: "itemOpacity"; value: 0.2 }


      PathLine { x: 0; y: 0 }
      PathAttribute { name: "itemScale"; value: 0 }
      PathAttribute { name: "itemOpacity"; value: 0 }
    }

    onCurrentItemChanged: {
      if (currentIndex !== previousIndex) {
        if (currentIndex > previousIndex) channelUpSound.play();
        if (currentIndex < previousIndex) channelDownSound.play();

        api.memory.set(Enums.MemoryKeys.LibraryChannelIndex, currentIndex);
      }

      previousIndex = currentIndex;
    }

    Component.onCompleted: {
      platformsList.currentIndex = api.memory.get(Enums.MemoryKeys.LibraryChannelIndex) || 0;
    }
  }

  PanelsList {
    id: gamesList
    model: currentPlatform.games
    anchors.top: platformsList.bottom
    anchors.left: platformsList.left
    anchors.right: parent.right
    anchors.leftMargin: vpx(3)
    anchors.topMargin: vpx(24)
    indexPersistenceKey: Enums.MemoryKeys.LibraryPanelIndex
    contentType: Styling.getIdealContentType(currentPlatform.games)
    delegate: PanelWrapper {
      property var contentType: parent.contentType
      property var posterBackground: contentType === Enums.PanelContentTypes.GameCover ? (assets.boxFront || assets.poster) : undefined
      property var backgroundSource: posterBackground || assets.steam || assets.background || assets.banner
      property var isCurrentItem: PathView.isCurrentItem

      Image {
        id: background
        height: parent.height
        width: parent.width
        sourceSize.width: width
        sourceSize.height: height
        source: backgroundSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
      }

      Image {
        id: fallbackBackground
        fillMode: Image.PreserveAspectCrop
        anchors.fill: background
        source: `../../assets/images/contenttabs/green/backgrounds/${index % 8 + 1}.png`
        visible: background.status != Image.Ready
        cache: true
      }

      onIsCurrentItemChanged: {
        if (isCurrentItem && icon.visible) {
          iconAnimation.start();
        }
      }

      SequentialAnimation {
        id: iconAnimation
        PauseAnimation {
          duration: 400
        }
        NumberAnimation {
          target: icon
          property: "scale"
          to: 1.4
          duration: 100
        }
        NumberAnimation {
          target: icon
          property: "scale"
          to: 1
          duration: 100
        }
      }

      Image {
        id: icon
        fillMode: Image.PreserveAspectFit
        source: assets.logo || "../../assets/images/contenttabs/green/icons/controller.png"
        visible: fallbackBackground.visible && background.status !== Image.Loading
        asynchronous: true
        cache: true
        anchors.fill: parent
        anchors.leftMargin: vpx(30)
        anchors.rightMargin: vpx(30)
        anchors.bottomMargin: vpx(30)
        anchors.topMargin: vpx(30)
        sourceSize.width: width
        sourceSize.height: height
      }

      Item {
        id: genericPanelOverlay
        width: parent.width
        height: parent.height
        visible: icon.visible || contentType === Enums.PanelContentTypes.GameGeneric

        LinearGradient {
          anchors.fill: parent
          start: Qt.point(0, 0)
          end: Qt.point(0, parent.height)
          gradient: Gradient {
            GradientStop { position: .64; color: "#00000000" }
            GradientStop { position: 1; color: "#DD000000" }
          }
        }

        StyledText {
          font.pixelSize: vpx(27)
          text: title
          anchors.bottom: summaryText.top
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: vpx(18)
          anchors.rightMargin: vpx(18)
          anchors.bottomMargin: vpx(4)
          elide: Text.ElideRight
        }

        StyledText {
          id: summaryText
          font.pixelSize: vpx(21)
          text: summary
          anchors.bottom: parent.bottom
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.leftMargin: vpx(18)
          anchors.rightMargin: vpx(18)
          anchors.bottomMargin: vpx(15)
          anchors.topMargin: vpx(20)
          opacity: .8
          elide: Text.ElideRight
          visible: !truncated
          maximumLineCount: 1
        }
      }
    }
  }

  StyledText {
    text: currentGame && `${gamesList.currentIndex + 1} of ${currentPlatform.games.count}  |  ${currentGame.title}`
    visible: currentGame
    anchors.top: gamesList.bottom
    anchors.topMargin: vpx(9) - vpx(Styling.panelReflectionSize)
    anchors.left: parent.left
    anchors.leftMargin: vpx(96)
    font.pixelSize: vpx(20)
    color: "#616161"
    layer.effect: DropShadow {
      verticalOffset: vpx(1)
      horizontalOffset: vpx(1)
      color: "#55FFFFFF"
      radius: vpx(2)
      samples: vpx(1)
    }
  }

  Component.onCompleted: {
    setAvailableActions({
      [Enums.ActionKeys.Bottom]: {
        label: "Seleziona",
        visible: true
      },
      [Enums.ActionKeys.Left]: {
        label: "Dettagli Applet",
        visible: true
      }
    });
  }
}
