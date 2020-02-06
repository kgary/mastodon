import React from 'react';
import PropTypes from 'prop-types';

export default class FutureSelfMenu extends React.PureComponent {

  static propTypes = {
    onClick: PropTypes.func.isRequired,
  };

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick();
  }

  reset = () => {
    this.setState({ addTag:true });
  }
  render () {
    return (
      <img src={require('../../../../images/future_self.png')} alt='future_self' style={{width: 23, height: 23}} onClick={this.handleClick} />
    );
  }

}
