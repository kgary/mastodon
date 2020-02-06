import React from 'react';
import PropTypes from 'prop-types';

export default class Maso_button extends React.PureComponent {

  static propTypes = {
    value: PropTypes.string.isRequired,
    title: PropTypes.string,
    bgColor: PropTypes.array,
    onClick: PropTypes.func.isRequired,
  };

  state = {
    addTag: true,
    bgColor: this.props.bgColor || ['white', 'blue'],
  }

  handleClick = (e) => {
    e.preventDefault();
    this.props.onClick(e, this.state.addTag);
    this.setState({ addTag:!this.state.addTag });
  }

  reset = () => {
    this.setState({ addTag:true });
  }
  render () {
    return (
      <button
        value={'#'+this.props.value}
        onClick={this.handleClick}
        style={{ backgroundColor:this.state.bgColor[this.state.addTag ? 0 : 1] }}
      >
        {this.props.value}
      </button>
    );
  }

}