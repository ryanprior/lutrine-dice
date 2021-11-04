component Floaty {
  property children : Array(Html) = []
  property show = true
  property onClose : Function(Html.Event, Promise(Never, Void)) = (event : Html.Event) { next {} }

  style outer {
    position: relative;
    width: 0px;
    height: 0px;
    if(!show) {
      display: none;
    }
  }

  style main {
    animation: floaty 6s ease-in-out infinite;
    color: #6d597a;
    font-weight: bold;
    background-color: #d4cbe5;
    padding: 6px 8px;
    border-radius: 9px;
    position: absolute;
    top: 40px;
    width: max-content;
    right: calc(100% + 10px);
    box-shadow: -6px 6px #a5cbc3;
    /* border: 1px solid $color-green;*/

    &:before {
      transform: translatex(0px);
      animation: floaty-tab 6s ease-in-out infinite;
      content: " ";
      /* -webkit-text-stroke: 0.5px $color-green;*/
      /* border: 1px solid $color-green;*/
      width: 35px;
      height: 11px;
      border-radius: 11px;
      background-color: #d4cbe5;
      position: absolute;
      display: block;
      top: -17px;
      right: 0px;
      box-shadow: -4px 4px #a5cbc3;
      z-index: 2000;
    }

    @keyframes floaty {
      0% {
        box-shadow: -6px 6px #a5cbc3;
        right: calc(100% + 10px);
      }
      50% {
        box-shadow: -8px 6px #a5cbc3;
        right: calc(100% + 12px);
      }
      100% {
        box-shadow: -6px 6px #a5cbc3;
        right: calc(100% + 10px);
      }
    }

    @keyframes floaty-tab {
      0% {
        transform: translatex(0px);
      }
      50% {
        transform: translatex(-4px);
      }
      0% {
        transform: translatex(0px);
      }
    }
  }

  style close {
    color: #6d597a;
    margin-left: 8px;
    cursor: pointer;
  }

  fun render {
    <div::outer>
      <div::main>
        <{ children }>
        <span::close title="Close" onClick={onClose}>"☒"</span>
      </div>
    </div>
  }
}
