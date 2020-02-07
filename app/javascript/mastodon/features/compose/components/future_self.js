import React from 'react';
import PropTypes from 'prop-types';
import IconButton from '../../../components/icon_button';

export default class FutureSelfMenu extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
  };

  state = { i: 0, active: false }

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick();
    this.setState({ i: this.state.i + 1 });
  }

  handleMouseDown = () => {
    this.setState({ active: !this.state.active });
  }

  reset = () => {
    this.setState({ addTag:true });
    this.setState({ active: false });
  }

  componentWillMount () {
    //TODO placeholder need to update with correct images
    this.options = [
      { icon: 'flag' },
    ];
  }
  render () {
    return (
      //this makes it a button with an image, but doesn't match look and feel of others
      // <button><img src={require('../../../../images/future_self.png')} alt='future_self' style={{width: 23, height: 23}} onClick={this.handleClick} /></button>
      <IconButton
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
