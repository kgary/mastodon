import React from 'react';
import PropTypes from 'prop-types';

export default class MasoButton extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    title: PropTypes.string,
    active: PropTypes.bool,
    onClick: PropTypes.func.isRequired,
  };

  state = {addTag:true}

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick(e, this.state.addTag);
    this.setState({addTag:!this.state.addTag});
  }

  render () {

    return (
      <button value={'#'+this.props.value} onClick={this.handleClick}>
        {this.props.value}
      </button>
    );
  }

}
