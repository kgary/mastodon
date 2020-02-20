import { connect } from 'react-redux';
import FutureSelfMenu from "../components/future_self";
import { changeComposeFutureSelf } from '../../../actions/compose';
import {isUserTouching} from "../../../is_mobile";

const mapStateToProps = (state, ownProps) => ({
  value: state.getIn(['compose', 'futureSelf']),
  // onClick: state.onClick,
});

const mapDispatchToProps = (dispatch, ownProps) => ({

  onChange (value) {
    dispatch(changeComposeFutureSelf(value));
  },
  isUserTouching,
  onClick: () => dispatch(ownProps.onClick),


});

export default connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(FutureSelfMenu);
