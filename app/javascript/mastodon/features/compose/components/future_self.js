import React from 'react';
import PropTypes from 'prop-types';
import IconButton from '../../../components/icon_button';

export default class FutureSelfMenu extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
    onChange: PropTypes.func.isRequired,
    disabled: PropTypes.bool.isRequired,
  };

  state = { i: 0, active: false }

  handleClick = (e) => {
    e.preventDefault();
    this.props.onChange(this.state.active);
    this.props.onClick();
    this.setState({ i: this.state.i + 1 });
  }

  handleMouseDown = () => {
    this.setState({ active: !this.state.active });
  }

  reset = () => {
    this.setState({ active: false });
  }

  componentWillMount () {
    //TODO placeholder need to update with correct images
    this.options = [
      { icon: 'graduation-cap' },
    ];
  }
  render () {
    return (
      <IconButton
        disabled={this.props.disabled}
        icon={this.options[this.state.i % this.options.length].icon} //need to figure out where to put our images so this works.
        title={'future_self'}
        size={18}
        active={this.state.active}
        inverted
        onClick={this.handleClick}
        onMouseDown={this.handleMouseDown}
        style={{ height: null, lineHeight: '27px' }}
      />
    );
  }

}
