<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="pageTitle" value="Salary rules"/>
<c:set var="activeNav" value="rules"/>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<style>
    /* Salary rules (FR-RULE-01..07). Shared look comes from app.css (pg-header, panel). */
    .rules-layout {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 340px;
        gap: 20px;
        align-items: start;
    }
    .rule-row {
        display: grid;
        grid-template-columns: minmax(0, 1fr) 210px;
        gap: 24px;
        align-items: center;
        padding: 16px 18px;
        border-top: 1px solid #eef0f3;
    }
    .panel-head + .rule-row { border-top: none; }
    .rule-title { display: block; font-size: 14px; font-weight: 600; color: var(--text); cursor: pointer; }
    .rule-spec { font-size: 13px; color: var(--muted); margin-top: 3px; line-height: 1.5; }
    .rule-key { display: inline-block; margin-top: 6px; font-family: var(--font-mono); font-size: 11.5px; color: #9ca3af; }

    .input-unit {
        display: flex;
        align-items: stretch;
        border: 1px solid #cbd5e1;
        border-radius: 6px;
        background: #ffffff;
        overflow: hidden;
        transition: border-color .15s ease, box-shadow .15s ease;
    }
    .input-unit:focus-within { border-color: #1d4ed8; box-shadow: 0 0 0 3px rgba(29, 78, 216, 0.12); }
    .input-unit input {
        flex: 1;
        min-width: 0;
        height: 38px;
        border: none !important;
        box-shadow: none !important;
        border-radius: 0;
        padding: 0 10px;
        text-align: right;
        font-size: 14px;
        font-weight: 600;
        font-variant-numeric: tabular-nums;
    }
    .input-unit span {
        display: flex;
        align-items: center;
        padding: 0 10px;
        background: #f8f9fb;
        border-left: 1px solid #e5e7eb;
        color: var(--muted);
        font-size: 12.5px;
        white-space: nowrap;
    }
    .rule-row.is-changed .input-unit { border-color: #b45309; }
    .rule-changed { font-size: 12px; color: #b45309; margin-top: 5px; text-align: right; min-height: 16px; }
    .rule-row.is-invalid .input-unit { border-color: #b91c1c; }

    .save-bar {
        position: sticky;
        bottom: 0;
        z-index: 20;
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 12px;
        padding: 12px 18px;
        background: #ffffff;
        border: 1px solid var(--border);
        border-radius: 8px;
        box-shadow: 0 -4px 16px rgba(16, 24, 40, 0.06);
    }
    .save-bar-status { font-size: 13px; color: var(--muted); }
    .save-bar.has-changes .save-bar-status { color: #b45309; font-weight: 600; }
    .save-bar-actions { display: flex; gap: 8px; }

    .formula-line { display: flex; justify-content: space-between; gap: 12px; padding: 9px 0; border-bottom: 1px dashed #e5e7eb; font-size: 13px; }
    .formula-line span:first-child { color: var(--text); font-weight: 500; }
    .formula-line span:last-child { color: var(--muted); text-align: right; }
    .formula-line b { color: var(--text); font-weight: 600; }
    .formula-total { margin-top: 12px; padding: 12px; background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 6px; font-size: 13px; color: #166534; line-height: 1.5; }
    .formula-total strong { display: block; margin-bottom: 2px; }

    @media (max-width: 1100px) {
        .rules-layout { grid-template-columns: 1fr; }
    }
    @media (max-width: 640px) {
        .rule-row { grid-template-columns: 1fr; gap: 10px; }
        .rule-changed { text-align: left; }
    }
</style>

<div class="pg-header">
    <div class="pg-header-text">
        <h1>Salary rules</h1>
        <p>The rates and limits used to calculate pay. Changes apply the next time a payroll is calculated or recalculated; locked payrolls are not affected.</p>
    </div>
    <div class="pg-header-actions">
        <a href="${ctx}/admin/holidays" class="btn btn-secondary">Public holidays</a>
        <a href="${ctx}/admin/payroll" class="btn btn-secondary">Payroll</a>
    </div>
</div>

<form method="post" action="${ctx}/admin/rules" id="rulesForm">
    <div class="rules-layout">
        <div>
            <%-- Groups: each rule key appears in exactly one group; unknown keys fall into "Other". --%>
            <c:forTokens var="group" delims="|"
                         items="Working time;standard_hours_per_month,grace_period_minutes;How long a normal month is and how late someone can be before it counts|Overtime;ot_weekday_multiplier,ot_weekend_multiplier,ot_holiday_multiplier;Pay rates for hours beyond 8 in a day, by type of day|Night work;night_allowance_multiplier,night_ot_multiplier;Extra pay for hours between 22:00 and 06:00|Late penalty;penalty_rate_per_minute;What is deducted for each minute late after the grace period|Fingerprint recognition;min_confidence;How sure the sensor must be before a scan is accepted">
                <c:set var="groupName" value=""/><c:set var="groupKeys" value=""/><c:set var="groupDesc" value=""/>
                <c:forTokens var="part" delims=";" items="${group}" varStatus="ps">
                    <c:if test="${ps.count == 1}"><c:set var="groupName" value="${part}"/></c:if>
                    <c:if test="${ps.count == 2}"><c:set var="groupKeys" value="${part}"/></c:if>
                    <c:if test="${ps.count == 3}"><c:set var="groupDesc" value="${part}"/></c:if>
                </c:forTokens>
                <section class="panel">
                    <div class="panel-head">
                        <div>
                            <h2>${groupName}</h2>
                            <p>${groupDesc}</p>
                        </div>
                    </div>
                    <c:forTokens var="k" items="${groupKeys}" delims=",">
                        <c:forEach var="r" items="${rules}">
                            <c:if test="${r.ruleKey == k}">
                                <%@ include file="rule-row.jspf" %>
                            </c:if>
                        </c:forEach>
                    </c:forTokens>
                </section>
            </c:forTokens>

            <c:set var="knownKeys" value=",standard_hours_per_month,grace_period_minutes,ot_weekday_multiplier,ot_weekend_multiplier,ot_holiday_multiplier,night_allowance_multiplier,night_ot_multiplier,penalty_rate_per_minute,min_confidence,"/>
            <c:set var="hasOther" value="false"/>
            <c:forEach var="r" items="${rules}">
                <c:set var="needle" value=",${r.ruleKey},"/>
                <c:if test="${not knownKeys.contains(needle)}"><c:set var="hasOther" value="true"/></c:if>
            </c:forEach>
            <c:if test="${hasOther}">
                <section class="panel">
                    <div class="panel-head"><div><h2>Other</h2><p>Additional settings stored in the rules table</p></div></div>
                    <c:forEach var="r" items="${rules}">
                        <c:set var="needle" value=",${r.ruleKey},"/>
                        <c:if test="${not knownKeys.contains(needle)}">
                            <%@ include file="rule-row.jspf" %>
                        </c:if>
                    </c:forEach>
                </section>
            </c:if>

            <div class="save-bar" id="saveBar">
                <span class="save-bar-status" id="saveStatus">No unsaved changes</span>
                <div class="save-bar-actions">
                    <button type="button" class="btn btn-secondary" id="discardBtn" disabled>Discard</button>
                    <button type="submit" class="btn btn-primary" id="saveBtn" disabled>Save rules</button>
                </div>
            </div>
        </div>

        <!-- How the rules combine (SRS section 5) -->
        <aside class="panel" style="position: sticky; top: 72px;">
            <div class="panel-head">
                <div>
                    <h2>How net pay is calculated</h2>
                    <p>Updates as you edit the values.</p>
                </div>
            </div>
            <div class="panel-body">
                <div class="formula-line"><span>Hourly rate</span><span>base salary &divide; <b data-rule-ref="standard_hours_per_month" data-format="hours"></b></span></div>
                <div class="formula-line"><span>Regular pay</span><span>regular hours &times; hourly rate</span></div>
                <div class="formula-line"><span>Weekday overtime</span><span>hours &times; rate &times; <b data-rule-ref="ot_weekday_multiplier" data-format="pct"></b></span></div>
                <div class="formula-line"><span>Weekend overtime</span><span>hours &times; rate &times; <b data-rule-ref="ot_weekend_multiplier" data-format="pct"></b></span></div>
                <div class="formula-line"><span>Holiday overtime</span><span>hours &times; rate &times; <b data-rule-ref="ot_holiday_multiplier" data-format="pct"></b></span></div>
                <div class="formula-line"><span>Night allowance</span><span>night hours &times; rate &times; <b data-rule-ref="night_allowance_multiplier" data-format="pct"></b></span></div>
                <div class="formula-line"><span>Night overtime bonus</span><span>night OT hours &times; rate &times; <b data-rule-ref="night_ot_multiplier" data-format="pct"></b></span></div>
                <div class="formula-line"><span>Late penalty</span><span>(minutes late &minus; <b data-rule-ref="grace_period_minutes" data-format="mins"></b>) &times; <b data-rule-ref="penalty_rate_per_minute" data-format="vndmin"></b></span></div>
                <div class="formula-total">
                    <strong>Net pay</strong>
                    regular pay + overtime + night allowance + night overtime bonus &minus; late penalty
                </div>
            </div>
        </aside>
    </div>
</form>

<script>
    // Builds each rule's title and explanation from its current value, so the text always matches
    // what PayrollCalculator / AttendanceService will apply. Also tracks unsaved changes.
    (function () {
        var num = function (v, maxFrac) {
            return v.toLocaleString('en-US', { maximumFractionDigits: maxFrac === undefined ? 2 : maxFrac });
        };
        var pct = function (v) { return num(v * 100, 1) + '%'; };
        var vnd = function (v) { return Math.round(v).toLocaleString('en-US') + ' VND'; };

        var RULES = {
            standard_hours_per_month: function (v) {
                return { title: 'Standard hours per month',
                    spec: 'Hourly rate = base salary ÷ ' + num(v) + ' h (about ' + num(v / 8, 1) + ' working days × 8 h). A 10,000,000 VND salary gives ' + vnd(10000000 / v) + ' per hour.' };
            },
            grace_period_minutes: function (v) {
                return { title: 'Late arrival grace period',
                    spec: v <= 0 ? 'No grace period: any check-in after the shift start is Late and every late minute is penalized. Applies to new scans immediately.'
                        : 'A check-in up to ' + num(v) + ' min after the shift start counts as On time; after that only the extra minutes are penalized. Applies to new scans immediately.' };
            },
            ot_weekday_multiplier: function (v) {
                return { title: 'Weekday overtime rate', spec: 'Hours beyond 8 on a Monday–Friday shift are paid at ' + pct(v) + ' of the hourly rate.' };
            },
            ot_weekend_multiplier: function (v) {
                return { title: 'Weekend overtime rate', spec: 'Overtime on Saturday or Sunday is paid at ' + pct(v) + ' of the hourly rate.' };
            },
            ot_holiday_multiplier: function (v) {
                return { title: 'Public holiday overtime rate', spec: 'Overtime on a date in the Public holidays calendar is paid at ' + pct(v) + ' of the hourly rate.' };
            },
            night_allowance_multiplier: function (v) {
                return { title: 'Night allowance', spec: 'Regular hours worked between 22:00 and 06:00 earn an extra ' + pct(v) + ' of the hourly rate.' };
            },
            night_ot_multiplier: function (v) {
                return { title: 'Night overtime bonus', spec: 'Overtime hours between 22:00 and 06:00 earn a further ' + pct(v) + ' of the hourly rate on top of overtime pay.' };
            },
            penalty_rate_per_minute: function (v) {
                return { title: 'Late penalty per minute', spec: 'Each minute late after the grace period deducts ' + vnd(v) + '. Ten minutes late costs ' + vnd(v * 10) + '.' };
            },
            min_confidence: function (v) {
                return { title: 'Minimum match confidence', spec: 'Scans with a sensor confidence below ' + num(v) + ' are rejected as "not recognized" and logged. Applies to new scans immediately.' };
            }
        };

        var REF_FORMATS = {
            pct: pct,
            hours: function (v) { return num(v) + ' h'; },
            mins: function (v) { return num(v) + ' min grace'; },
            vndmin: function (v) { return vnd(v) + '/min'; }
        };

        var inputs = Array.prototype.slice.call(document.querySelectorAll('.input-unit input[data-rule-key]'));
        var saveBar = document.getElementById('saveBar');
        var saveStatus = document.getElementById('saveStatus');
        var saveBtn = document.getElementById('saveBtn');
        var discardBtn = document.getElementById('discardBtn');

        function sameNumber(a, b) {
            var x = Number(a), y = Number(b);
            return a.trim() !== '' && isFinite(x) && isFinite(y) && x === y;
        }

        function render(input) {
            var key = input.getAttribute('data-rule-key');
            var row = input.closest('.rule-row');
            var raw = input.value.trim();
            var v = raw === '' ? NaN : Number(raw);
            var valid = isFinite(v);
            var describe = RULES[key];

            var titleEl = row.querySelector('.rule-title');
            var specEl = row.querySelector('.rule-spec');
            if (describe) {
                if (valid) {
                    var d = describe(v);
                    titleEl.textContent = d.title;
                    specEl.textContent = d.spec;
                } else {
                    specEl.textContent = 'Enter a number to see how this rule is applied.';
                }
            }
            row.classList.toggle('is-invalid', !valid);

            var changed = !sameNumber(input.value, input.defaultValue);
            row.classList.toggle('is-changed', changed && valid);
            row.querySelector('.rule-changed').textContent = changed && valid ? 'Changed from ' + num(Number(input.defaultValue), 4) : '';

            document.querySelectorAll('[data-rule-ref="' + key + '"]').forEach(function (el) {
                var fmt = REF_FORMATS[el.getAttribute('data-format')] || num;
                el.textContent = valid ? fmt(v) : '?';
            });
        }

        function refreshSaveBar() {
            var changed = inputs.filter(function (i) { return !sameNumber(i.value, i.defaultValue); }).length;
            var invalid = inputs.some(function (i) { return !isFinite(Number(i.value)) || i.value.trim() === ''; });
            saveBar.classList.toggle('has-changes', changed > 0);
            saveStatus.textContent = invalid ? 'Fix the highlighted value before saving'
                : changed === 0 ? 'No unsaved changes'
                : changed + (changed === 1 ? ' unsaved change' : ' unsaved changes');
            saveBtn.disabled = changed === 0 || invalid;
            discardBtn.disabled = changed === 0;
        }

        inputs.forEach(function (input) {
            // Show stored decimals without trailing zeros (5.00 -> 5, 1.50 -> 1.5); the saved value is unchanged.
            var clean = Number(input.value);
            if (input.value.trim() !== '' && isFinite(clean)) input.defaultValue = input.value = String(clean);
            render(input);
            input.addEventListener('input', function () { render(input); refreshSaveBar(); });
        });
        refreshSaveBar();

        discardBtn.addEventListener('click', function () {
            inputs.forEach(function (i) { i.value = i.defaultValue; render(i); });
            refreshSaveBar();
        });

        var submitting = false;
        document.getElementById('rulesForm').addEventListener('submit', function () { submitting = true; });
        window.addEventListener('beforeunload', function (e) {
            if (submitting) return;
            if (inputs.some(function (i) { return !sameNumber(i.value, i.defaultValue); })) {
                e.preventDefault();
                e.returnValue = '';
            }
        });
    })();
</script>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
