import Immutable from 'immutable';
import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';
import classNames from 'classnames';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { createSelector } from 'reselect';
import { fetchStatus } from '../../actions/statuses';
import MissingIndicator from '../../components/missing_indicator';
import DetailedStatus from './components/detailed_status';
import ActionBar from './components/action_bar';
import Column from '../ui/components/column';
import {
  favourite,
  unfavourite,
  reblog,
  unreblog,
  pin,
  unpin,
} from '../../actions/interactions';
import {
  replyCompose,
  mentionCompose,
  directCompose,
  goalCompose,
} from '../../actions/compose';
import {
  muteStatus,
  unmuteStatus,
  deleteStatus,
  hideStatus,
  revealStatus,
} from '../../actions/statuses';
import { initMuteModal } from '../../actions/mutes';
import { initBlockModal } from '../../actions/blocks';
import { initReport } from '../../actions/reports';
import { makeGetStatus } from '../../selectors';
import { ScrollContainer } from 'react-router-scroll-4';
import ColumnBackButton from '../../components/column_back_button';
import ColumnHeader from '../../components/column_header';
import StatusContainer from '../../containers/status_container';
import { openModal } from '../../actions/modal';
import { defineMessages, injectIntl } from 'react-intl';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { HotKeys } from 'react-hotkeys';
import { boostModal, deleteModal } from '../../initial_state';
import { attachFullscreenListener, detachFullscreenListener, isFullscreen } from '../ui/util/fullscreen';
import { textForScreenReader, defaultMediaVisibility } from '../../components/status';
import Icon from 'mastodon/components/icon';

const messages = defineMessages({
  deleteConfirm: { id: 'confirmations.delete.confirm', defaultMessage: 'Delete' },
  deleteMessage: { id: 'confirmations.delete.message', defaultMessage: 'Are you sure you want to delete this status?' },
  redraftConfirm: { id: 'confirmations.redraft.confirm', defaultMessage: 'Delete & redraft' },
  redraftMessage: { id: 'confirmations.redraft.message', defaultMessage: 'Are you sure you want to delete this status and re-draft it? Favourites and boosts will be lost, and replies to the original post will be orphaned.' },
  revealAll: { id: 'status.show_more_all', defaultMessage: 'Show more for all' },
  hideAll: { id: 'status.show_less_all', defaultMessage: 'Show less for all' },
  detailedStatus: { id: 'status.detailed_status', defaultMessage: 'Detailed conversation view' },
  replyConfirm: { id: 'confirmations.reply.confirm', defaultMessage: 'Reply' },
  replyMessage: { id: 'confirmations.reply.message', defaultMessage: 'Replying now will overwrite the message you are currently composing. Are you sure you want to proceed?' },
});

const makeMapStateToProps = () => {
  const getStatus = makeGetStatus();

  const getAncestorsIds = createSelector([
    (_, { id }) => id,
    state => state.getIn(['contexts', 'inReplyTos']),
  ], (statusId, inReplyTos) => {
    let ancestorsIds = Immutable.List();
    ancestorsIds = ancestorsIds.withMutations(mutable => {
      let id = statusId;

      while (id) {
        mutable.unshift(id);
        id = inReplyTos.get(id);
      }
    });

    return ancestorsIds;
  });

  const getDescendantsIds = createSelector([
    (_, { id }) => id,
    state => state.getIn(['contexts', 'replies']),
    state => state.get('statuses'),
  ], (statusId, contextReplies, statuses) => {
    let descendantsIds = [];
    const ids = [statusId];

    while (ids.length > 0) {
      let id        = ids.shift();
      const replies = contextReplies.get(id);

      if (statusId !== id) {
        descendantsIds.push(id);
      }

      if (replies) {
        replies.reverse().forEach(reply => {
          ids.unshift(reply);
        });
      }
    }

    let insertAt = descendantsIds.findIndex((id) => statuses.get(id).get('in_reply_to_account_id') !== statuses.get(id).get('account'));
    if (insertAt !== -1) {
      descendantsIds.forEach((id, idx) => {
        if (idx > insertAt && statuses.get(id).get('in_reply_to_account_id') === statuses.get(id).get('account')) {
          descendantsIds.splice(idx, 1);
          descendantsIds.splice(insertAt, 0, id);
          insertAt += 1;
        }
      });
    }

    return Immutable.List(descendantsIds);
  });

  const mapStateToProps = (state, props) => {
    const status = getStatus(state, { id: props.params.statusId });
    let ancestorsIds = Immutable.List();
    let descendantsIds = Immutable.List();

    if (status) {
      ancestorsIds = getAncestorsIds(state, { id: status.get('in_reply_to_id') });
      descendantsIds = getDescendantsIds(state, { id: status.get('id') });
    }

    return {
      status,
      ancestorsIds,
      descendantsIds,
      askReplyConfirmation: state.getIn(['compose', 'text']).trim().length !== 0,
      domain: state.getIn(['meta', 'domain']),
    };
  };

  return mapStateToProps;
};

export default @injectIntl
@connect(makeMapStateToProps)
class Status extends ImmutablePureComponent {

  static contextTypes = {
    router: PropTypes.object,
  };

  static propTypes = {
    params: PropTypes.object.isRequired,
    dispatch: PropTypes.func.isRequired,
    status: ImmutablePropTypes.map,
    ancestorsIds: ImmutablePropTypes.list,
    descendantsIds: ImmutablePropTypes.list,
    intl: PropTypes.object.isRequired,
    askReplyConfirmation: PropTypes.bool,
    multiColumn: PropTypes.bool,
    domain: PropTypes.string.isRequired,
  };

  state = {
    fullscreen: false,
    showMedia: defaultMediaVisibility(this.props.status),
    loadedStatusId: undefined,
  };

  componentWillMount () {
    this.props.dispatch(fetchStatus(this.props.params.statusId));
  }

  componentDidMount () {
    attachFullscreenListener(this.onFullScreenChange);
  }

  componentWillReceiveProps (nextProps) {
    if (nextProps.params.statusId !== this.props.params.statusId && nextProps.params.statusId) {
      this._scrolledIntoView = false;
      this.props.dispatch(fetchStatus(nextProps.params.statusId));
    }

    if (nextProps.status && nextProps.status.get('id') !== this.state.loadedStatusId) {
      this.setState({ showMedia: defaultMediaVisibility(nextProps.status), loadedStatusId: nextProps.status.get('id') });
    }
  }

  handleToggleMediaVisibility = () => {
    this.setState({ showMedia: !this.state.showMedia });
  }

  handleFavouriteClick = (status) => {
    if (status.get('favourited')) {
      this.props.dispatch(unfavourite(status));
    } else {
      this.props.dispatch(favourite(status));
    }
  }

  handlePin = (status) => {
    if (status.get('pinned')) {
      this.props.dispatch(unpin(status));
    } else {
      this.props.dispatch(pin(status));
    }
  }

  handleReplyClick = (status) => {
    let { askReplyConfirmation, dispatch, intl } = this.props;
    if (askReplyConfirmation) {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(messages.replyMessage),
        confirm: intl.formatMessage(messages.replyConfirm),
        onConfirm: () => dispatch(replyCompose(status, this.context.router.history)),
      }));
    } else {
      dispatch(replyCompose(status, this.context.router.history));
    }
  }

  handleGoalClick = (status) => {
    let { askReplyConfirmation, dispatch, intl } = this.props;
    if (askReplyConfirmation) {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(messages.replyMessage),
        confirm: intl.formatMessage(messages.replyConfirm),
        onConfirm: () => dispatch(goalCompose(status, this.context.router.history)),
      }));
    } else {
      dispatch(goalCompose(status, this.context.router.history));
    }
  }

  handleModalReblog = (status) => {
    this.props.dispatch(reblog(status));
  }

  handleReblogClick = (status, e) => {
    if (status.get('reblogged')) {
      this.props.dispatch(unreblog(status));
    } else {
      if ((e && e.shiftKey) || !boostModal) {
        this.handleModalReblog(status);
      } else {
        this.props.dispatch(openModal('BOOST', { status, onReblog: this.handleModalReblog }));
      }
    }
  }

  handleDeleteClick = (status, history, withRedraft = false) => {
    const { dispatch, intl } = this.props;

    if (!deleteModal) {
      dispatch(deleteStatus(status.get('id'), history, withRedraft));
    } else {
      dispatch(openModal('CONFIRM', {
        message: intl.formatMessage(withRedraft ? messages.redraftMessage : messages.deleteMessage),
        confirm: intl.formatMessage(withRedraft ? messages.redraftConfirm : messages.deleteConfirm),
        onConfirm: () => dispatch(deleteStatus(status.get('id'), history, withRedraft)),
      }));
    }
  }

  handleDirectClick = (account, router) => {
    this.props.dispatch(directCompose(account, router));
  }

  handleMentionClick = (account, router) => {
    this.props.dispatch(mentionCompose(account, router));
  }

  handleOpenMedia = (media, index) => {
    this.props.dispatch(openModal('MEDIA', { media, index }));
  }

  handleOpenVideo = (media, time) => {
    this.props.dispatch(openModal('VIDEO', { media, time }));
  }

  handleMuteClick = (account) => {
    this.props.dispatch(initMuteModal(account));
  }

  handleConversationMuteClick = (status) => {
    if (status.get('muted')) {
      this.props.dispatch(unmuteStatus(status.get('id')));
    } else {
      this.props.dispatch(muteStatus(status.get('id')));
    }
  }

  handleToggleHidden = (status) => {
    if (status.get('hidden')) {
      this.props.dispatch(revealStatus(status.get('id')));
    } else {
      this.props.dispatch(hideStatus(status.get('id')));
    }
  }

  handleToggleAll = () => {
    const { status, ancestorsIds, descendantsIds } = this.props;
    const statusIds = [status.get('id')].concat(ancestorsIds.toJS(), descendantsIds.toJS());

    if (status.get('hidden')) {
      this.props.dispatch(revealStatus(statusIds));
    } else {
      this.props.dispatch(hideStatus(statusIds));
    }
  }

  handleBlockClick = (status) => {
    const { dispatch } = this.props;
    const account = status.get('account');
    dispatch(initBlockModal(account));
  }

  handleReport = (status) => {
    this.props.dispatch(initReport(status.get('account'), status));
  }

  handleEmbed = (status) => {
    this.props.dispatch(openModal('EMBED', { url: status.get('url') }));
  }

  onModalReblog (status) {
    if (status.get('reblogged')) {
      dispatch(unreblog(status));
    } else {
      dispatch(reblog(status));
    }
  }

  handleHotkeyMoveUp = () => {
    this.handleMoveUp(this.props.status.get('id'));
  }

  handleHotkeyMoveDown = () => {
    this.handleMoveDown(this.props.status.get('id'));
  }

  handleHotkeyReply = e => {
    e.preventDefault();
    this.handleReplyClick(this.props.status);
  }

  handleHotkeyFavourite = () => {
    this.handleFavouriteClick(this.props.status);
  }

  handleHotkeyBoost = () => {
    this.handleReblogClick(this.props.status);
  }

  handleHotkeyMention = e => {
    e.preventDefault();
    this.handleMentionClick(this.props.status.get('account'));
  }

  handleHotkeyOpenProfile = () => {
    this.context.router.history.push(`/accounts/${this.props.status.getIn(['account', 'id'])}`);
  }

  handleHotkeyToggleHidden = () => {
    this.handleToggleHidden(this.props.status);
  }

  handleHotkeyToggleSensitive = () => {
    this.handleToggleMediaVisibility();
  }

  handleMoveUp = id => {
    const { status, ancestorsIds, descendantsIds } = this.props;

    if (id === status.get('id')) {
      this._selectChild(ancestorsIds.size - 1, true);
    } else {
      let index = ancestorsIds.indexOf(id);

      if (index === -1) {
        index = descendantsIds.indexOf(id);
        this._selectChild(ancestorsIds.size + index, true);
      } else {
        this._selectChild(index - 1, true);
      }
    }
  }

  handleMoveDown = id => {
    const { status, ancestorsIds, descendantsIds } = this.props;

    if (id === status.get('id')) {
      this._selectChild(ancestorsIds.size + 1, false);
    } else {
      let index = ancestorsIds.indexOf(id);

      if (index === -1) {
        index = descendantsIds.indexOf(id);
        this._selectChild(ancestorsIds.size + index + 2, false);
      } else {
        this._selectChild(index + 1, false);
      }
    }
  }

  _selectChild (index, align_top) {
    const container = this.node;
    const element = container.querySelectorAll('.focusable')[index];

    if (element) {
      if (align_top && container.scrollTop > element.offsetTop) {
        element.scrollIntoView(true);
      } else if (!align_top && container.scrollTop + container.clientHeight < element.offsetTop + element.offsetHeight) {
        element.scrollIntoView(false);
      }
      element.focus();
    }
  }

  renderChildren (list) {
    return list.map(id => (
      <StatusContainer
        key={id}
        id={id}
        onMoveUp={this.handleMoveUp}
        onMoveDown={this.handleMoveDown}
        contextType='thread'
      />
    ));
  }

  setRef = c => {
    this.node = c;
  }

  componentDidUpdate () {
    if (this._scrolledIntoView) {
      return;
    }

    const { status, ancestorsIds } = this.props;

    if (status && ancestorsIds && ancestorsIds.size > 0) {
      const element = this.node.querySelectorAll('.focusable')[ancestorsIds.size - 1];

      window.requestAnimationFrame(() => {
        element.scrollIntoView(true);
      });
      this._scrolledIntoView = true;
    }
  }

  componentWillUnmount () {
    detachFullscreenListener(this.onFullScreenChange);
  }

  onFullScreenChange = () => {
    this.setState({ fullscreen: isFullscreen() });
  }

  render () {
    let ancestors, descendants;
    const { shouldUpdateScroll, status, ancestorsIds, descendantsIds, intl, domain, multiColumn } = this.props;
    const { fullscreen } = this.state;

    if (status === null) {
      return (
        <Column>
          <ColumnBackButton multiColumn={multiColumn} />
          <MissingIndicator />
        </Column>
      );
    }

    if (ancestorsIds && ancestorsIds.size > 0) {
      ancestors = <div>{this.renderChildren(ancestorsIds)}</div>;
    }

    if (descendantsIds && descendantsIds.size > 0) {
      descendants = <div>{this.renderChildren(descendantsIds)}</div>;
    }

    const handlers = {
      moveUp: this.handleHotkeyMoveUp,
      moveDown: this.handleHotkeyMoveDown,
      reply: this.handleHotkeyReply,
      favourite: this.handleHotkeyFavourite,
      boost: this.handleHotkeyBoost,
      mention: this.handleHotkeyMention,
      openProfile: this.handleHotkeyOpenProfile,
      toggleHidden: this.handleHotkeyToggleHidden,
      toggleSensitive: this.handleHotkeyToggleSensitive,
    };

    return (
      <Column bindToDocument={!multiColumn} label={intl.formatMessage(messages.detailedStatus)}>
        <ColumnHeader
          showBackButton
          multiColumn={multiColumn}
          extraButton={(
            <button className='column-header__button' title={intl.formatMessage(status.get('hidden') ? messages.revealAll : messages.hideAll)} aria-label={intl.formatMessage(status.get('hidden') ? messages.revealAll : messages.hideAll)} onClick={this.handleToggleAll} aria-pressed={status.get('hidden') ? 'false' : 'true'}><Icon id={status.get('hidden') ? 'eye-slash' : 'eye'} /></button>
          )}
        />

        <ScrollContainer scrollKey='thread' shouldUpdateScroll={shouldUpdateScroll}>
          <div className={classNames('scrollable', { fullscreen })} ref={this.setRef}>
            {ancestors}

            <HotKeys handlers={handlers}>
              <div className={classNames('focusable', 'detailed-status__wrapper')} tabIndex='0' aria-label={textForScreenReader(intl, status, false)}>
                <DetailedStatus
                  status={status}
                  onOpenVideo={this.handleOpenVideo}
                  onOpenMedia={this.handleOpenMedia}
                  onToggleHidden={this.handleToggleHidden}
                  domain={domain}
                  showMedia={this.state.showMedia}
                  onToggleMediaVisibility={this.handleToggleMediaVisibility}
                />

                <ActionBar
                  status={status}
                  onReply={this.handleReplyClick}
                  onFavourite={this.handleFavouriteClick}
                  onReblog={this.handleReblogClick}
                  onDelete={this.handleDeleteClick}
                  onDirect={this.handleDirectClick}
                  onMention={this.handleMentionClick}
                  onMute={this.handleMuteClick}
                  onMuteConversation={this.handleConversationMuteClick}
                  onBlock={this.handleBlockClick}
                  onReport={this.handleReport}
                  onPin={this.handlePin}
                  onEmbed={this.handleEmbed}
                  onGoal={this.handleGoalClick}
                />
              </div>
            </HotKeys>

            {descendants}
          </div>
        </ScrollContainer>
      </Column>
    );
  }

}
