import React from 'react';
import CharacterCounter from './character_counter';
import Button from '../../../components/button';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import ReplyIndicatorContainer from '../containers/reply_indicator_container';
import AutosuggestTextarea from '../../../components/autosuggest_textarea';
import AutosuggestInput from '../../../components/autosuggest_input';
import PollButtonContainer from '../containers/poll_button_container';
import UploadButtonContainer from '../containers/upload_button_container';
import { defineMessages, injectIntl } from 'react-intl';
import PrivacyDropdownContainer from '../containers/privacy_dropdown_container';
import EmojiPickerDropdown from '../containers/emoji_picker_dropdown_container';
import PollFormContainer from '../containers/poll_form_container';
import UploadFormContainer from '../containers/upload_form_container';
import WarningContainer from '../containers/warning_container';
import { isMobile } from '../../../is_mobile';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { length } from 'stringz';
import { countableText } from '../util/counter';
import Icon from 'mastodon/components/icon';
import MasoButton from './maso_button';
import FutureSelfContainer from '../containers/future_self_container';
import GoalForm from './goal_form';
// import FutureSelfMenu from './future_self';
import CheckButton from '../../../components/goal_checkbox';

const allowedAroundShortCode = '><\u0085\u0020\u00a0\u1680\u2000\u2001\u2002\u2003\u2004\u2005\u2006\u2007\u2008\u2009\u200a\u202f\u205f\u3000\u2028\u2029\u0009\u000a\u000b\u000c\u000d';

const messages = defineMessages({
  placeholder: { id: 'compose_form.placeholder', defaultMessage: 'What is on your mind?' },
  spoiler_placeholder: { id: 'compose_form.spoiler_placeholder', defaultMessage: 'Write your warning here' },
  publish: { id: 'compose_form.publish', defaultMessage: 'Post' },
  publishLoud: { id: 'compose_form.publish_loud', defaultMessage: '{publish}!' },
});

export default @injectIntl
class ComposeForm extends ImmutablePureComponent {

  DEFAULT_TAG_STRING = 'FutureSelf TAGS:'
  FUTURE_SELF_TEXT_THRESHOLD = 10;
  CHECKLIST_BG_COLOR = 'rgba(255, 255, 255, 0.1)';

  constructor() {
    super();
    this.masoFamily = React.createRef();
    this.masoCareer = React.createRef();
    this.masoFriends = React.createRef();
    this.masoHealth = React.createRef();
    this.masoLifestyle = React.createRef();
    this.masoCommunity = React.createRef();
    this.futureSelfContainer = React.createRef();
  }

  static contextTypes = {
    router: PropTypes.object,
  };
  static propTypes = {
    intl: PropTypes.object.isRequired,
    text: PropTypes.string.isRequired,
    suggestions: ImmutablePropTypes.list,
    spoiler: PropTypes.bool,
    privacy: PropTypes.string,
    spoilerText: PropTypes.string,
    futureSelf: PropTypes.bool,
    focusDate: PropTypes.instanceOf(Date),
    caretPosition: PropTypes.number,
    preselectDate: PropTypes.instanceOf(Date),
    isSubmitting: PropTypes.bool,
    isChangingUpload: PropTypes.bool,
    isUploading: PropTypes.bool,
    onChange: PropTypes.func.isRequired,
    onSubmit: PropTypes.func.isRequired,
    onClearSuggestions: PropTypes.func.isRequired,
    onFetchSuggestions: PropTypes.func.isRequired,
    onSuggestionSelected: PropTypes.func.isRequired,
    onChangeSpoilerText: PropTypes.func.isRequired,
    onPaste: PropTypes.func.isRequired,
    onPickEmoji: PropTypes.func.isRequired,
    showSearch: PropTypes.bool,
    anyMedia: PropTypes.bool,
    singleColumn: PropTypes.bool,
  };

  static defaultProps = {
    showSearch: false,
  };

  state = {
    tagString: this.DEFAULT_TAG_STRING,
    futureSelf: false,
    hasTag: false,
    hasImage: false,
    hasText: false,
    goal: '',
    goalImportance: '',
    goalPlan: '',
  };

  handleChange = (e) => {
    this.props.onChange(e.target.value);
    this.setState({ hasText: this.autosuggestTextarea.textarea.value.length >= this.FUTURE_SELF_TEXT_THRESHOLD });
  }

  checkFutureSelfReqs = (anyMedia, text) => {
    this.setState({ hasText: text === null ?
      false : text.length >= this.FUTURE_SELF_TEXT_THRESHOLD });
    this.setState({ hasImage: anyMedia });
    this.setState({ hasTag: this.state.tagString !== this.DEFAULT_TAG_STRING });
  }

  handleKeyDown = (e) => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleSubmit();
    }
  }

  showFutureSelf = () => {

    this.setState({ futureSelf: !this.state.futureSelf });
    this.resetMastoButton();
  }

  updateTootTag = (e, addTag) => {
    if(addTag) {
      // this.props.onChange(this.props.text + e.target.value);
      this.setState({ tagString: this.state.tagString + ' ' + e.target.value });
      this.setState({ hasTag: true });
    } else {
      // this.props.onChange(this.props.text.replace(e.target.value, ''));
      this.setState({ tagString: this.state.tagString.replace(' ' + e.target.value, '') });
    }
  }

  resetMastoButton = () => {
    try {
      this.masoFamily.current.reset();
      this.masoCareer.current.reset();
      this.masoFriends.current.reset();
      this.masoHealth.current.reset();
      this.masoLifestyle.current.reset();
      this.masoCommunity.current.reset();
      this.futureSelfContainer.current.reset();
      this.setState({ futureSelf: false });
      this.setState({ tagString: this.DEFAULT_TAG_STRING });
    } catch (e) {
      console.log('futureSelf is already reset');
    }
  }


  resetGoal = () => {
    this.setState({ goal: '' });
    this.setState({ goalImportance: '' });
    this.setState({ goalPlan: '' });
  }

  handleGoalChange = e => {
    this.setState({ goal: e.target.value });
  };

  handleGoalImportanceChange = e => {
    this.setState({ goalImportance: e.target.value });
  };

  handleGoalPlanChange = e => {
    this.setState({ goalPlan: e.target.value });
  };

  goalText = () => {
    if(this.props.goal)
      return this.state.goal+','+this.state.goalImportance+','+this.state.goalPlan;
    return '';
  }

  handleSubmit = () => {
    if (this.props.text !== this.autosuggestTextarea.textarea.value) {
      // Something changed the text inside the textarea (e.g. browser extensions like Grammarly)
      // Update the state to match the current text
      this.props.onChange(this.autosuggestTextarea.textarea.value);
    }

    // Submit disabled:
    const { isSubmitting, isChangingUpload, isUploading, anyMedia, goal} = this.props;
    const fulltext = [this.props.spoilerText, countableText(this.props.text)].join('');
    if (isSubmitting || isUploading || isChangingUpload || length(fulltext) > 500 || (fulltext.length !== 0 && fulltext.trim().length === 0 && !anyMedia)
      || (goal && (length(this.autosuggestTextarea.textarea.value) === 0 || length(this.state.goal) === 0
      || length(this.state.goalImportance) === 0 || length(this.state.goalPlan) === 0))) {
      return;
    }

    if (this.state.futureSelf) {
      this.setState({ hasTag: this.state.tagString !== this.DEFAULT_TAG_STRING });
      this.setState({ hasImage: anyMedia });
      this.setState({ hasText: this.autosuggestTextarea.textarea.value.length > 100 });
      if(this.state.tagString === this.DEFAULT_TAG_STRING || !anyMedia || this.autosuggestTextarea.textarea.value.length < this.FUTURE_SELF_TEXT_THRESHOLD){
        return;
      }
      this.props.onChange(this.autosuggestTextarea.textarea.value + ' #futureSelf' + this.state.tagString.replace('FutureSelf TAGS:', ''));
      this.resetMastoButton();
    }

    if (goal) {
      this.props.onChange(
        // 'My Goal is:\n'
        // + this.autosuggestTextarea.textarea.value
        // + '\n\nThe goal is important to me because:'
        // + '\n'+this.state.goalImportance
        // + '\n\nTo achieve this goal I will:'
        // + '\n'+this.state.goalPlan);
        this.goalText());
      this.resetGoal();
    }

    this.props.onSubmit(this.context.router ? this.context.router.history : null);
  }

  onSuggestionsClearRequested = () => {
    this.props.onClearSuggestions();
  }

  onSuggestionsFetchRequested = (token) => {
    this.props.onFetchSuggestions(token);
  }

  onSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['text']);
  }

  onSpoilerSuggestionSelected = (tokenStart, token, value) => {
    this.props.onSuggestionSelected(tokenStart, token, value, ['spoiler_text']);
  }

  handleChangeSpoilerText = (e) => {
    this.props.onChangeSpoilerText(e.target.value);
  }

  handleFocus = () => {
    if (this.composeForm && !this.props.singleColumn) {
      const { left, right } = this.composeForm.getBoundingClientRect();
      if (left < 0 || right > (window.innerWidth || document.documentElement.clientWidth)) {
        this.composeForm.scrollIntoView();
      }
    }
  }

  componentDidUpdate (prevProps) {
    // This statement does several things:
    // - If we're beginning a reply, and,
    //     - Replying to zero or one users, places the cursor at the end of the textbox.
    //     - Replying to more than one user, selects any usernames past the first;
    //       this provides a convenient shortcut to drop everyone else from the conversation.
    if (this.props.focusDate !== prevProps.focusDate) {
      let selectionEnd, selectionStart;

      if (this.props.preselectDate !== prevProps.preselectDate) {
        selectionEnd   = this.props.text.length;
        selectionStart = this.props.text.search(/\s/) + 1;
      } else if (typeof this.props.caretPosition === 'number') {
        selectionStart = this.props.caretPosition;
        selectionEnd   = this.props.caretPosition;
      } else {
        selectionEnd   = this.props.text.length;
        selectionStart = selectionEnd;
      }

      this.autosuggestTextarea.textarea.setSelectionRange(selectionStart, selectionEnd);
      this.autosuggestTextarea.textarea.focus();
    } else if(prevProps.isSubmitting && !this.props.isSubmitting) {
      this.autosuggestTextarea.textarea.focus();
    } else if (this.props.spoiler !== prevProps.spoiler) {
      if (this.props.spoiler) {
        this.spoilerText.input.focus();
      } else {
        this.autosuggestTextarea.textarea.focus();
      }
    }

    // if(this.state.goal === '' && this.props.goal && this.props.text.value !== '')
    //   this.parseGoal(this.props.text.value);
  }

  // /**
  //  * 'My Goal is:\n'
  //  + this.autosuggestTextarea.textarea.value
  //  + '\n\nThe goal is important to me because:'
  //  + '\n'+this.state.goalImportance
  //  + '\n\nTo achieve this goal I will:'
  //  + '\n'+this.state.goalPlan);
  //  * @param text
  //  */
  // parseGoal = (text) => {
  //   try {
  //     // alert(text);
  //     // text = text.slice(3,-4); //remove the <p></p>
  //     let goalStrings = text.split(',');
  //     alert(goalStrings);
  //     this.setState({ goal: goalStrings[0] });
  //     this.setState({ goalImportance: goalStrings[1] });
  //     this.setState({ goalPlan: goalStrings[2] });
  //   } catch (e) {
  //     this.setState({ goal: 'oops there' });
  //     this.setState({ goalImportance: 'was an error' });
  //     this.setState({ goalPlan: e });
  //   }
  // }

  setAutosuggestTextarea = (c) => {
    this.autosuggestTextarea = c;
  }

  setSpoilerText = (c) => {
    this.spoilerText = c;
  }

  setRef = c => {
    this.composeForm = c;
  };

  handleEmojiPick = (data) => {
    const { text }     = this.props;
    const position     = this.autosuggestTextarea.textarea.selectionStart;
    const needsSpace   = data.custom && position > 0 && !allowedAroundShortCode.includes(text[position - 1]);

    this.props.onPickEmoji(position, data, needsSpace);
  }

  render () {
    // alert(this.props.futureSelf);
    const { intl, onPaste, showSearch, anyMedia, goal } = this.props;
    const disabled = this.props.isSubmitting;
    const text     = [this.props.spoilerText, countableText(this.props.text)].join('');
    const disabledButton = disabled || this.props.isUploading || this.props.isChangingUpload || length(text) > 500 || (text.length !== 0 && text.trim().length === 0 && !anyMedia);
    let publishText = '';

    if (this.props.privacy === 'private' || this.props.privacy === 'direct') {
      publishText = <span className='compose-form__publish-private'><Icon id='lock' /> {intl.formatMessage(messages.publish)}</span>;
    } else {
      publishText = this.props.privacy !== 'unlisted' ? intl.formatMessage(messages.publishLoud, { publish: intl.formatMessage(messages.publish) }) : intl.formatMessage(messages.publish);
    }

    //update future self checks
    this.checkFutureSelfReqs(anyMedia, text);
    if(goal)
      this.resetMastoButton();
    else
      this.resetGoal()
    // this.setState({ hasImage: anyMedia });
    // this.setState({ hasTag: this.state.tagString !== this.DEFAULT_TAG_STRING });
    // console.log(JSON.stringify(intl, null, 2));
    // if(this.state.goal === '' && goal && this.props.text !== '')
    //   this.parseGoal(this.props.text); // TODO

    return (
      <div className='compose-form'>
        <WarningContainer />

        <ReplyIndicatorContainer />

        <div className={`spoiler-input ${this.props.spoiler ? 'spoiler-input--visible' : ''}`} ref={this.setRef}>
          <AutosuggestInput
            placeholder={intl.formatMessage(messages.spoiler_placeholder)}
            value={this.props.spoilerText}
            onChange={this.handleChangeSpoilerText}
            onKeyDown={this.handleKeyDown}
            disabled={!this.props.spoiler}
            ref={this.setSpoilerText}
            suggestions={this.props.suggestions}
            onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
            onSuggestionsClearRequested={this.onSuggestionsClearRequested}
            onSuggestionSelected={this.onSpoilerSuggestionSelected}
            searchTokens={[':']}
            id='cw-spoiler-input'
            className='spoiler-input__input'
          />
        </div>
        {/*if we are drafting a goal show goal form*/}
        {goal &&  //TODO update this to be the goal form
        <AutosuggestTextarea
          ref={this.setAutosuggestTextarea}
          placeholder='My goal is...'
          disabled
          value={'Create Your Goal'}
          onChange={this.handleChange}
          suggestions={this.props.suggestions}
          onFocus={this.handleFocus}
          onKeyDown={this.handleKeyDown}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
          onPaste={onPaste}
          autoFocus={!showSearch && !isMobile(window.innerWidth)}
          goal={goal}
        >
          <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />
          <div className='compose-form__modifiers'>
            <GoalForm
              goal={this.state.goal}
              goalImportance={this.state.goalImportance}
              goalPlan={this.state.goalPlan}
              handleGoalChange={this.handleGoalChange}
              handleGoalImportanceChange={this.handleGoalImportanceChange}
              handleGoalPlanChange={this.handleGoalPlanChange}
            />
            <UploadFormContainer />
            <PollFormContainer />
          </div>
        </AutosuggestTextarea>
        }
        {/*otherwise be a normal text area*/}
        {!goal && <AutosuggestTextarea
          ref={this.setAutosuggestTextarea}
          placeholder={intl.formatMessage(messages.placeholder)}
          disabled={disabled}
          value={this.props.text}
          onChange={this.handleChange}
          suggestions={this.props.suggestions}
          onFocus={this.handleFocus}
          onKeyDown={this.handleKeyDown}
          onSuggestionsFetchRequested={this.onSuggestionsFetchRequested}
          onSuggestionsClearRequested={this.onSuggestionsClearRequested}
          onSuggestionSelected={this.onSuggestionSelected}
          onPaste={onPaste}
          autoFocus={!showSearch && !isMobile(window.innerWidth)}
        >
          <EmojiPickerDropdown onPickEmoji={this.handleEmojiPick} />
          <div className='compose-form__modifiers'>
            <UploadFormContainer />
            <PollFormContainer />
          </div>
        </AutosuggestTextarea> }


        <div className='compose-form__buttons-wrapper'>
          <div className='compose-form__buttons'>
            <UploadButtonContainer />
            <PollButtonContainer />
            <PrivacyDropdownContainer />
            {/*<FutureSelfMenu onClick={this.showFutureSelf} />*/}
            <FutureSelfContainer disabled={goal} active={this.props.futureSelf} onClick={this.showFutureSelf} ref={this.futureSelfContainer} />
          </div>
          <div className='character-counter__wrapper'><CharacterCounter max={500} text={text + this.goalText()} /></div>
        </div>
        {(this.state.futureSelf || this.props.futureSelf) && <div>
          <div class='compose-form__buttons-wrapper-bridges'>
            <MasoButton value={'family'} onClick={this.updateTootTag} ref={this.masoFamily} bgColor={['#E8F8F7', '#14BBB0']}  />
            <MasoButton value={'career'} onClick={this.updateTootTag} ref={this.masoCareer} bgColor={['#FDE6F4', '#EA088D']} />
            <MasoButton value={'friends'} onClick={this.updateTootTag} ref={this.masoFriends} bgColor={['#FFFAE6', '#FFCB06']}   />
            <MasoButton value={'health'} onClick={this.updateTootTag} ref={this.masoHealth} bgColor={['#F6FAEB', '#A4CD39']}   />
            <MasoButton value={'lifestyle'} onClick={this.updateTootTag} ref={this.masoLifestyle} bgColor={['#E6F7FB', '#00B1D4']} />
            <MasoButton value={'community'} onClick={this.updateTootTag} ref={this.masoCommunity} bgColor={['#F4EDF5', '#8f4A9B']} />
          </div>
          {!this.state.hasImage && <div>
            <CheckButton />
            add an image of your future self.
          </div>}
          {this.state.hasImage && <div>
            <CheckButton icon='check' />
            add an image of your future self. </div>}
          {!this.state.hasTag && <div>
            <CheckButton />
            tag your image with categories. </div>}
          {this.state.hasTag && <div>
            <CheckButton icon='check' />
            tag your image with  categories. </div>}
          {!this.state.hasText && <div>
            <CheckButton />
            write about why you chose the image.
            <CheckButton bgColor='' />
            req char count: {this.FUTURE_SELF_TEXT_THRESHOLD - (this.props.text.length || 0)} </div>}
          {this.state.hasText && <div>
            <CheckButton icon='check' />
            write about why you chose the image. </div>}
        </div> }
        <div className='compose-form__publish'>
          <div className='compose-form__publish-button-wrapper'>
            <Button
              text='Post'
              style={{ fontSize:'100' }}
              onClick={this.handleSubmit}
              disabled={disabledButton
              || (this.state.futureSelf
                && (!this.state.hasImage //TODO
                  || !this.state.hasTag
                  || !this.state.hasText))}
              block
            />
          </div>
        </div>
      </div>
    );
  }

}
