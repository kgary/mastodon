import { connect } from 'react-redux';
import GoalContainer from "../components/goal";
import { changeComposeGoal } from '../../../actions/compose';
import {isUserTouching} from "../../../is_mobile";

const mapStateToProps = (state, ownProps) => ({
  value: state.getIn(['compose', 'goal']),
});

const mapDispatchToProps = (dispatch, ownProps) => ({

  onChange (value) {
    dispatch(changeComposeGoal(value));
  },
  isUserTouching,
  onClick: () => dispatch(ownProps.onClick),


});

export default connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(GoalContainer);
