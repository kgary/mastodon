import { connect } from 'react-redux';
import GoalMenu from "../components/goals";
import { changeComposeGoals } from '../../../actions/compose';
import {isUserTouching} from "../../../is_mobile";

const mapStateToProps = (state, ownProps) => ({
  value: state.getIn(['compose', 'goals']),
  // onClick: state.onClick,
});

const mapDispatchToProps = (dispatch, ownProps) => ({

  onChange (value) {
    dispatch(changeComposeGoals(value));
  },
  isUserTouching,
  onClick: () => dispatch(ownProps.onClick),


});

export default connect(mapStateToProps, mapDispatchToProps, null, { forwardRef: true })(GoalMenu);
