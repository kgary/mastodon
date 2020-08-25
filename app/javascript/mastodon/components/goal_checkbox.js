import React from 'react';
import Motion from '../features/ui/util/optional_motion';
import spring from 'react-motion/lib/spring';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import Icon from 'mastodon/components/icon';

export default class CheckButton extends React.PureComponent {

  static propTypes = {
    className: PropTypes.string,
    title: PropTypes.string.isRequired,
    icon: PropTypes.string.isRequired,
    size: PropTypes.number,
    active: PropTypes.bool,
    pressed: PropTypes.bool,
    expanded: PropTypes.bool,
    style: PropTypes.object,
    activeStyle: PropTypes.object,
    disabled: PropTypes.bool,
    inverted: PropTypes.bool,
    animate: PropTypes.bool,
    overlay: PropTypes.bool,
    tabIndex: PropTypes.string,
    bgColor: PropTypes.string,
    margin: PropTypes.number,
    iconColor: PropTypes.string,
  };

  static defaultProps = {
    size: 20,
    active: false,
    icon: '',
    bgCOlor: '',
    disabled: true,
    animate: false,
    overlay: false,
    tabIndex: '0',
    bgColor: 'rgba(255, 255, 255, 0.1)',
    margin: 4,
    iconColor: '#3778FF',
  };

  render () {
    const style = {
      fontSize: `${this.props.size}px`,
      width: `${this.props.size * 1.28571429}px`,
      height: `${this.props.size * 1.28571429}px`,
      lineHeight: `${this.props.size}px`,
      backgroundColor: this.props.bgColor,
      marginTop: this.props.margin,
      marginRight: this.props.margin,
      ...this.props.style,
      ...(this.props.active ? this.props.activeStyle : {}),
    };

    const {
      active,
      animate,
      className,
      disabled,
      expanded,
      icon,
      inverted,
      overlay,
      pressed,
      tabIndex,
      title,
      iconColor,
    } = this.props;

    const classes = classNames(className, 'icon-button', {
      active,
      disabled,
      inverted,
      overlayed: overlay,
    });

    if (!animate) {
      // Perf optimization: avoid unnecessary <Motion> components unless
      // we actually need to animate.
      return (
        <button
          aria-label={title}
          aria-pressed={pressed}
          aria-expanded={expanded}
          title={title}
          className={classes}
          style={style}
          tabIndex={tabIndex}
          disabled={disabled}
        >
          <Icon id={icon} fixedWidth aria-hidden='true' color={iconColor} />
        </button>
      );
    }

    return (
      <Motion defaultStyle={{ rotate: active ? -360 : 0 }} style={{ rotate: animate ? spring(active ? -360 : 0, { stiffness: 120, damping: 7 }) : 0 }}>
        {({ rotate }) => (
          <button
            aria-label={title}
            aria-pressed={pressed}
            aria-expanded={expanded}
            title={title}
            className={classes}
            style={style}
            tabIndex={tabIndex}
            disabled={disabled}
          >
            <Icon id={icon} color={iconColor} style={{ transform: `rotate(${rotate}deg)` }} fixedWidth aria-hidden='true' />
          </button>
        )}
      </Motion>
    );
  }

}
