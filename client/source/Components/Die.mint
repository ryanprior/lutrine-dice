component Die {
  property sides : Number
  property face : Number
  property big : Bool

  style illustration {
    if(big) {
      width: 4.5rem;
      vertical-align: middle;
      animation: #{
        case (face) {
          20 => "nat-20 6s linear infinite"
          1  => ""
             => "big-die 6s linear infinite"
        }
      };
    } else {
      width: #{if(face == 20) {"2.5"} else {"1.5"}}rem;
      vertical-align: middle;
      filter: grayscale(0.8);
    }

    @keyframes nat-20 {
      0%, 100% {
        transform: scale(0.98) rotate(0deg);
      }
      25% {
        transform: scale(0.9933) rotate(2deg);
      }
      50% {
        transform: scale(1.02) rotate(0deg);
      }

      75% {
        transform: scale(0.9933) rotate(-2deg);
      }
    }

    @keyframes big-die {
      0%, 100% {
        transform: translate(0px, 0px) scale(0.98);
      }
      10% {
        transform: translate(0.4px, -.5px) scale(0.988);
      }
      20% {
        transform: translate(-.2px, -.2px) scale(0.996);
      }
      30% {
        transform: translate(.3px, -.4px) scale(1.004);
      }
      40% {
        transform: translate(.3px, 0.2px) scale(1.012);
      }
      50% {
        transform: translate(0.5px, 0px) scale(1.02);
      }
      60% {
        transform: translate(-.1px, -.1px) scale(1.012);
      }
      70% {
        transform: translate(.4px, -.2px) scale(1.004);
      }
      80% {
        transform: translate(0px, -.5px) scale(0.996);
      }
      90% {
        transform: translate(-.5px, -0.3px) scale(0.98);
      }
    }
  }

  fun render : Html {
    case (sides) {
      4  => <img::illustration src={@asset(../../assets/d4.png)} alt="" title="1d4" />
      6  => <img::illustration src={@asset(../../assets/d6.png)} alt="" title="1d6" />
      8  => <img::illustration src={@asset(../../assets/d8.png)} alt="" title="1d8" />
      10 => <img::illustration src={@asset(../../assets/d10.png)} alt="" title="1d10`" />
      12 => <img::illustration src={@asset(../../assets/d12.png)} alt="" title="1d12" />
      20 => case (face) {
        1  => <img::illustration src={@asset(../../assets/d20-nat1.png)} alt="" title="Natural 1!" />
        20 => <img::illustration src={@asset(../../assets/d20-nat20.png)} alt="" title="Natural 20!" />
           => <img::illustration src={@asset(../../assets/d20.png)} alt="" title="1d20" />
      }
         => <></>
    }
  }
}
