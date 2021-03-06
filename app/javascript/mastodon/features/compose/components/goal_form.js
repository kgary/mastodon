import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Textarea from 'react-textarea-autosize';

export default
@injectIntl
class GoalForm extends ImmutablePureComponent {

  static propTypes = {
    value: PropTypes.string,
    suggestions: ImmutablePropTypes.list,
    disabled: PropTypes.bool,
    placeholder: PropTypes.string,
    onChange: PropTypes.func,
    onKeyUp: PropTypes.func,
    onKeyDown: PropTypes.func,
    autoFocus: PropTypes.bool,
    className: PropTypes.string,
    id: PropTypes.string,
    maxLength: PropTypes.number,
    handleGoalChange: PropTypes.func,
    handleGoalImportanceChange: PropTypes.func,
    handleGoalPlanChange: PropTypes.func,
  };

  handleGoalImportanceChange = e => {
    this.setState({ goalImportance: e.target.value });
    this.props.handleGoalImportanceChange(e);
  };

  handleGoalPlanChange = e => {
    this.setState({ goalPlan: e.target.value });
    this.props.handleGoalPlanChange(e);
  };

  handleGoalChange = e => {
    this.setState({ goal: e.target.value });
    this.props.handleGoalChange(e);
  };

  state = {
    goal: this.props.goal || '',
    goalImportance: this.props.goalImportance || '',
    goalPlan: this.props.goalPlan || '',
  }


  render () {
    const { value, suggestions, disabled, placeholder, onKeyUp, autoFocus, className, id, maxLength } = this.props;
    const styleA = { direction: 'ltr', backgroundColor:'rgba(0,0,0,0)', marginBottom: 10, color:'#272b37', fontSize: 14 };
    const styleB = { borderRadius: '4px 4px 0 0', display: 'block', width: '100%', border: '1px solid #000', padding: 10, boxSizing: 'border-box', direction: 'ltr', fontSize: 14, resize: 'none', backgroundColor: 'rgba(0,0,0,.2)', /*border: 'none', outlineColor: 'rgba(0,0,0,.25)'*/};
    // const styleB = { border: '1px solid #000', width: 400, direction: 'ltr', fontSize: 14, resize: 'none', backgroundColor: 'rgba(0,0,0,.2)', /*border: 'none', outlineColor: 'rgba(0,0,0,.25)'*/};


    if(!this.props.display || null) {
      return (
        <div className='form-container'>
          <form className='simple_form'>
            <div className='fields-group'>
              <div className='input with_label'>
                <div className='label_input'>
                  <label style={{ color: '#272b37' }}>
                    My Goal is:
                  </label>
                  <div className='label_input__wrapper'>
                    <Textarea
                      type='text'
                      ref={this.setInput}
                      disabled={false}
                      placeholder={'...'}
                      value={this.state.goal}
                      onChange={this.handleGoalChange}
                      onKeyDown={this.onKeyDown}
                      onKeyUp={onKeyUp}
                      onFocus={this.onFocus}
                      onBlur={this.onBlur}
                      style={styleA}
                      aria-autocomplete='list'
                      id={'goalInput'}
                      // className='input-copy'
                      // maxLength={25}
                    />
                  </div>
                </div>
              </div>
            </div>
            <div className='fields-group'>
              <div className='input with_label'>
                <div className='label_input'>
                  <label style={{ color: '#272b37' }}>
                    The goal is important to me because:
                  </label>
                  <div className='label_input__wrapper'>
                    <Textarea
                      type='text'
                      ref={this.setInput}
                      disabled={false}
                      placeholder={'...'}
                      value={this.state.goalImportance}
                      onChange={this.handleGoalImportanceChange}
                      onKeyDown={this.onKeyDown}
                      onKeyUp={onKeyUp}
                      onFocus={this.onFocus}
                      onBlur={this.onBlur}
                      style={styleA}
                      aria-autocomplete='list'
                      id={'goalImportanceInput'}
                      // className='input-copy'
                      // maxLength={25}
                    />
                  </div>
                </div>
              </div>
            </div>
            <div className='fields-group'>
              <div className='input with_label'>
                <div className='label_input'>
                  <label style={{ color: '#272b37' }}>
                    To achieve this goal I will:
                  </label>
                  <div className='label_input__wrapper'>
                    <Textarea
                      type='text'
                      ref={this.setInput}
                      disabled={false}
                      placeholder={'...'}
                      value={this.state.goalPlan}
                      onChange={this.handleGoalPlanChange}
                      onKeyDown={this.onKeyDown}
                      onKeyUp={onKeyUp}
                      onFocus={this.onFocus}
                      onBlur={this.onBlur}
                      style={styleA}
                      aria-autocomplete='list'
                      id={'goalPlanInput'}
                    />
                  </div>
                </div>
              </div>
            </div>
          </form>
        </div>
      );
    } else {
      {
        return (
          <div className='form-container'>
            <form className='simple_form'>
              <div className='fields-group'>
                <div className='input with_label'>
                  <div className='label_input'>
                    <label>
                      My Goal is:
                    </label>
                    <div className='label_input__wrapper'>
                      <div className='goal-textarea__textarea' style={styleB} dangerouslySetInnerHTML={{__html: this.props.goal}} />
                      {/*<Textarea*/}
                      {/*  type='text'*/}
                      {/*  ref={this.setInput}*/}
                      {/*  disabled*/}
                      {/*  placeholder={'...'}*/}
                      {/*  value={this.props.goal}*/}
                      {/*  onChange={this.handleGoalChange}*/}
                      {/*  onKeyDown={this.onKeyDown}*/}
                      {/*  onKeyUp={onKeyUp}*/}
                      {/*  onFocus={this.onFocus}*/}
                      {/*  onBlur={this.onBlur}*/}
                      {/*  style={styleB}*/}
                      {/*  aria-autocomplete='list'*/}
                      {/*  id={'goal'}*/}
                      {/*  // className='input-copy'*/}
                      {/*  // maxLength={25}*/}
                      {/*/>*/}
                    </div>
                  </div>
                </div>
              </div>
              <div className='fields-group'>
                <div className='input with_label'>
                  <div className='label_input'>
                    <label>
                      The goal is important to me because:
                    </label>
                    <div className='label_input__wrapper'>
                      <div className='goal-textarea__textarea' style={styleB} dangerouslySetInnerHTML={{__html: this.props.goalImportance}} />
                      {/*<Textarea*/}
                      {/*  type='text'*/}
                      {/*  ref={this.setInput}*/}
                      {/*  disabled*/}
                      {/*  placeholder={'...'}*/}
                      {/*  value={this.props.goalImportance}*/}
                      {/*  onChange={this.handleGoalImportanceChange}*/}
                      {/*  onKeyDown={this.onKeyDown}*/}
                      {/*  onKeyUp={onKeyUp}*/}
                      {/*  onFocus={this.onFocus}*/}
                      {/*  onBlur={this.onBlur}*/}
                      {/*  style={styleB}*/}
                      {/*  aria-autocomplete='list'*/}
                      {/*  id={'goalImportance'}*/}
                      {/*  // resize*/}
                      {/*  // className='input-copy'*/}
                      {/*  // maxLength={25}*/}
                      {/*/>*/}
                    </div>
                  </div>
                </div>
              </div>
              <div className='fields-group'>
                <div className='input with_label'>
                  <div className='label_input'>
                    <label>
                      To achieve this goal I will:
                    </label>
                    <div className='label_input__wrapper'>
                      <div className='goal-textarea__textarea' style={styleB} dangerouslySetInnerHTML={{__html: this.props.goalPlan}} />
                      {/*<Textarea*/}
                      {/*  type='text'*/}
                      {/*  ref={this.setInput}*/}
                      {/*  disabled*/}
                      {/*  placeholder={'...'}*/}
                      {/*  value={this.props.goalPlan}*/}
                      {/*  onChange={this.handleGoalPlanChange}*/}
                      {/*  onKeyDown={this.onKeyDown}*/}
                      {/*  onKeyUp={onKeyUp}*/}
                      {/*  onFocus={this.onFocus}*/}
                      {/*  onBlur={this.onBlur}*/}
                      {/*  style={styleB}*/}
                      {/*  aria-autocomplete='list'*/}
                      {/*  id={'goalPlan'}*/}
                      {/*  // className='input-copy'*/}
                      {/*  // maxLength={25}*/}
                      {/*/>*/}
                    </div>
                  </div>
                </div>
              </div>
            </form>
          </div>
        );
      }
    }
  }

}
