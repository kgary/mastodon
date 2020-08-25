import React from 'react';
import PropTypes from 'prop-types';
import classNames from 'classnames';

export default class Icon extends React.PureComponent {

  static propTypes = {
    id: PropTypes.string.isRequired,
    className: PropTypes.string,
    fixedWidth: PropTypes.bool,
    color: PropTypes.string,
  };

  render () {
    const { id, className, fixedWidth, color, ...other } = this.props;
    return (
      <i role='img' style={{ color:this.props.color }} className={classNames('fa', `fa-${id}`, className, { 'fa-fw': fixedWidth })} {...other} />
    );
  }

}
